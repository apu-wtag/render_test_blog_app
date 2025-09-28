class Article < ApplicationRecord
  include Discard::Model
  extend FriendlyId
  friendly_id :title, use: [ :slugged, :history ]
  attr_writer :topic_name
  attr_accessor :author_note

  validates :topic, presence: true
  validates :title, presence: true
  validate :content_must_not_be_empty
  before_validation :set_topic_from_name
  after_save :sync_blobs_from_content

  has_many :article_blob_links, dependent: :destroy
  has_many :blobs, through: :article_blob_links, source: :blob
  has_many :claps, dependent: :destroy
  has_many :clapped_users, through: :claps, source: :user
  has_many :comments, dependent: :destroy
  has_many :reports, as: :reportable, dependent: :destroy
  has_many :moderation_records, dependent: :destroy
  belongs_to :topic
  belongs_to :user

  scope :archived, -> { where.not(archived_at: nil) }
  scope :not_archived, -> { where(archived_at: nil) }
  scope :kept, -> { undiscarded.not_archived }

  def topic_name
    @topic_name || self.topic&.name
  end
  def should_generate_new_friendly_id?
    title_changed? || slug.blank?
  end
  def referenced_blob_signed_ids
    return [] if content.blank?
    begin
      JSON.parse(content)["blocks"]
        .filter { |block| [ "image", "attaches" ].include?(block["type"]) }
        .map { |block| block.dig("data", "file", "signed_id") }
        .flatten  # <-- THIS IS THE FIX: Flattens any nested arrays from bad data
        .compact  # Remove any nils
        .uniq     # Get only unique IDs
    rescue JSON::ParserError
      [] # Safely return empty if JSON is bad
    end
  end
  private
  def set_topic_from_name
    # Do nothing if the topic_name string is blank
    return unless @topic_name.present?

    # Find a topic with that name OR create a new one.
    # .strip removes any accidental leading/trailing whitespace.
    self.topic = Topic.find_or_create_by(name: @topic_name.strip)
  end
  def content_must_not_be_empty
    # First, check if content is just nil or a totally blank string
    if content.blank?
      errors.add(:content, "can't be blank")
      return # Stop here
    end

    # If content is present, check if it's an "empty" Editor.js object
    begin
      parsed_content = JSON.parse(content)
      # Add an error IF the "blocks" key is missing OR if the "blocks" array is empty.
      if parsed_content["blocks"].blank?
        errors.add(:content, "can't be blank")
      end
    rescue JSON::ParserError
      # If the content isn't valid JSON for some reason, count it as blank.
      errors.add(:content, "can't be blank")
    end
  end

  def sync_blobs_from_content
    # 1. Get blob IDs referenced in the JSON (returns an Array)
    signed_ids_from_json = self.referenced_blob_signed_ids

    # 2. Find all corresponding blobs from that Array
    # current_blob_ids = ActiveStorage::Blob.find_signed(signed_ids_from_json).map(&:id)
    blobs = signed_ids_from_json.map do |signed_id|
      ActiveStorage::Blob.find_signed(signed_id)
    end
    current_blob_ids = blobs.compact.map(&:id)
    # 3. Get blob IDs already linked in the database table
    linked_blob_ids = self.article_blob_links.pluck(:active_storage_blob_id)

    # 4. Delete old links (blobs in DB but NOT in JSON)
    ids_to_unlink = linked_blob_ids - current_blob_ids
    self.article_blob_links.where(active_storage_blob_id: ids_to_unlink).destroy_all

    # 5. Add new links (blobs in JSON but NOT in DB)
    ids_to_link = current_blob_ids - linked_blob_ids

    if ids_to_link.any?
      new_links = ids_to_link.map do |blob_id|
        {
          article_id: self.id,
          active_storage_blob_id: blob_id,
          created_at: Time.current,
          updated_at: Time.current
        }
      end
      # Use insert_all for one fast SQL query
      ArticleBlobLink.insert_all(
        new_links,
        unique_by: [ :article_id, :active_storage_blob_id ]
      )

      # ArticleBlobLink.insert_all(new_links, unique_by: :index_article_blob_links_on_article_id_and_active_storage_blob_id)
    end
  end
end
