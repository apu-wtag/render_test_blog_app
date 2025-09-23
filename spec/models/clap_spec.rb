require 'rails_helper'

RSpec.describe Clap, type: :model do
  describe "Validations" do
    subject { create(:clap) }
    it "validates that a user can only clap once per article" do
      should validate_uniqueness_of(:user_id).scoped_to(:article_id)
    end
  end

  describe "Associations" do
    it { should belong_to(:user) }
    it { should belong_to(:article).counter_cache(true) }
  end
  describe "Functionality" do
    let(:article) { create(:article) }

    context "when a clap is created" do
      it "increments the article's claps_count" do
        expect {
          create(:clap, article: article)
        }.to change { article.reload.claps_count }.by(1)
      end
    end

    context "when a clap is destroyed" do
      let!(:clap) { create(:clap, article: article) }

      it "decrements the article's claps_count" do
        expect {
          clap.destroy
        }.to change { article.reload.claps_count }.by(-1)
      end
    end
  end
end
