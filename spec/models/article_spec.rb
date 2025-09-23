require 'rails_helper'

RSpec.describe Article, type: :model do
  describe "Validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:topic) }

    context "custom content validation" do
      let(:user) { create(:user) }
      let(:topic) { create(:topic) }

      it "is invalid if content is nil" do
        article = build(:article, content: nil)
        expect(article).not_to be_valid
        expect(article.errors[:content]).to include("can't be blank")
      end

      it "is invalid if content is an empty JSON object" do
        article = build(:article, content: '{}')
        expect(article).not_to be_valid
        expect(article.errors[:content]).to include("can't be blank")
      end

      it "is invalid if content's 'blocks' array is empty" do
        article = build(:article, content: '{"blocks":[]}')
        expect(article).not_to be_valid
        expect(article.errors[:content]).to include("can't be blank")
      end

      it "is valid if content has blocks" do
        article = build(:article)
        expect(article).to be_valid
      end
    end
  end

  describe "Associations" do
    it { should belong_to(:user) }
    it { should belong_to(:topic) }
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_many(:claps).dependent(:destroy) }
    it { should have_many(:reports).dependent(:destroy) }
    it { should have_many(:moderation_records).dependent(:destroy) }
    it { should have_many(:article_blob_links).dependent(:destroy) }
    it { should have_many(:blobs).through(:article_blob_links) }
  end

  describe "Scopes" do
    let!(:kept_article) { create(:article) }
    let!(:discarded_article) { create(:article, :discarded) }
    let!(:archived_article) { create(:article, :archived) }

    it ".kept returns only kept articles" do
      expect(Article.kept).to contain_exactly(kept_article)
    end

    it ".discarded returns only discarded articles" do
      expect(Article.discarded).to contain_exactly(discarded_article)
    end

    it ".archived returns only archived articles" do
      expect(Article.archived).to contain_exactly(archived_article)
    end
  end

  describe "Callbacks" do
    context "#set_topic_from_name" do
      let!(:existing_topic) { create(:topic, name: "Existing Topic") }

      it "finds an existing topic by name" do
        article = create(:article, topic: nil, topic_name: "Existing Topic")
        expect(article.topic).to eq(existing_topic)
      end

      it "creates a new topic if one does not exist" do
        expect {
          create(:article, topic: nil, topic_name: "A Brand New Topic")
        }.to change(Topic, :count).by(1)
      end
    end

    context "#sync_blobs_from_content" do
      it "is called after save" do
        article = build(:article)
        # only calling test not functionality
        expect(article).to receive(:sync_blobs_from_content)
        article.save!
      end
    end
  end

  describe "FriendlyId" do
    it "creates a slug from the title" do
      article = create(:article, title: "A Great New Title")
      expect(article.slug).to eq("a-great-new-title")
    end
  end
end
