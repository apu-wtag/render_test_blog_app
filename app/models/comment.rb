class Comment < ApplicationRecord
  include Discard::Model
  validates :body, presence: true
  belongs_to :user
  belongs_to :article, counter_cache: true
  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy
  has_many :reports, as: :reportable, dependent: :destroy
  scope :kept, -> { undiscarded.joins(:article).merge(Article.kept) }
  after_discard do
    replies.find_each(&:discard)
  end
  after_undiscard do
    replies.find_each(&:undiscard)
  end
end
