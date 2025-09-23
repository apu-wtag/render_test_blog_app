require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe "validations" do
    it { should validate_presence_of(:body) }
  end

  describe "Associations" do
    it { should belong_to(:user) }
    it { should belong_to(:article).counter_cache(true) }
    it { should belong_to(:parent).class_name('Comment').optional }
    it { should have_many(:replies).class_name('Comment').with_foreign_key('parent_id').dependent(:destroy) }
    it { should have_many(:reports).dependent(:destroy) }
  end

  describe "Counter Cache" do
    let(:article) { create(:article) }

    it "increments the article's comments_count on creation" do
      expect {
        create(:comment, article: article)
      }.to change { article.reload.comments_count }.by(1)
    end

    it "decrements the article's comments_count on destruction" do
      comment = create(:comment, article: article)
      expect {
        comment.destroy
      }.to change { article.reload.comments_count }.by(-1)
    end
  end

  describe "Scopes" do
    describe ".kept" do
      let(:kept_article) { create(:article) }
      let(:discarded_article) { create(:article, :discarded) }

      let!(:kept_comment_on_kept_article) { create(:comment, article: kept_article) }
      let!(:discarded_comment_on_kept_article) { create(:comment, :discarded, article: kept_article) }
      let!(:kept_comment_on_discarded_article) { create(:comment, article: discarded_article) }

      it "only returns comments that are not discarded" do
        expect(Comment.kept).to include(kept_comment_on_kept_article)
        expect(Comment.kept).not_to include(discarded_comment_on_kept_article)
      end

      it "only returns comments whose parent article is not discarded" do
        expect(Comment.kept).to include(kept_comment_on_kept_article)
        expect(Comment.kept).not_to include(kept_comment_on_discarded_article)
      end

      it "returns a collection containing only the truly kept comment" do
        expect(Comment.kept).to contain_exactly(kept_comment_on_kept_article)
      end
    end
  end

  describe "Callbacks for Replies (Discard)" do
    let(:parent_comment) { create(:comment) }
    let!(:reply1) { create(:comment, parent: parent_comment, article: parent_comment.article) }
    let!(:reply2) { create(:comment, parent: parent_comment, article: parent_comment.article) }

    context "when a parent comment is discarded" do
      it "discards all of its replies" do
        parent_comment.discard

        expect(reply1.reload.discarded?).to be true
        expect(reply2.reload.discarded?).to be true
      end
    end

    context "when a parent comment is restored" do
      before do
        parent_comment.discard
      end

      it "restores all of its replies" do
        parent_comment.undiscard

        expect(reply1.reload.kept?).to be true
        expect(reply2.reload.kept?).to be true
      end
    end
  end
end
