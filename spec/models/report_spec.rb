require 'rails_helper'

RSpec.describe Report, type: :model do
  describe "Validations" do
    it { should validate_presence_of(:reason) }
    it { should validate_length_of(:reason).is_at_least(10) }
  end

  describe "Associations" do
    it { should belong_to(:user) }
    it { should belong_to(:reportable) }
  end

  describe "Enums" do
    it do
      should define_enum_for(:status).with_values(
        pending: 0,
        resolved: 1,
        dismissed: 2
      ).backed_by_column_of_type(:integer)
    end
  end

  describe "Polymorphic Behavior" do
    let(:user) { create(:user) }
    let(:article) { create(:article) }
    let(:comment) { create(:comment) }
    let(:clap) { create(:clap) }

    it "is valid when reportable is an Article" do
      report = build(:report, user: user, reportable: article)
      expect(report).to be_valid
      expect(report.reportable_type).to eq('Article')
    end

    it "is valid when reportable is a Comment" do
      report = build(:report, user: user, reportable: comment)
      expect(report).to be_valid
      expect(report.reportable_type).to eq('Comment')
    end
  end
end
