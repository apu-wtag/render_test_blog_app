require 'rails_helper'

RSpec.describe Topic, type: :model do
  subject { create(:topic) }

  describe "Validations" do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe "Associations" do
    it { should have_many(:articles).dependent(:nullify) }
  end

  describe "FriendlyId" do
    it "creates a slug from the name when a topic is created" do
      topic = create(:topic, name: "Science Fiction")
      expect(topic.slug).to eq("science-fiction")
    end

    it "updates the slug when the name changes" do
      topic = create(:topic, name: "Technology News")
      topic.update(name: "Updated Tech News")
      expect(topic.slug).to eq("updated-tech-news")
    end
  end
end
