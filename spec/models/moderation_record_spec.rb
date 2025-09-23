require 'rails_helper'

RSpec.describe ModerationRecord, type: :model do
  describe "Associations" do
    it { should belong_to(:article) }
    it { should belong_to(:admin).class_name('User') }
  end

  describe "Enums" do
    it do
      should define_enum_for(:status).with_values(
        hidden: 0,
        pending_review: 1,
        approved: 2,
        rejected: 3
      ).backed_by_column_of_type(:integer)
    end
  end

  describe "Functionality" do
    it "is valid with valid attributes" do
      expect(build(:moderation_record)).to be_valid
    end

    it "is associated with a user who is an admin" do
      moderation_record = create(:moderation_record)
      expect(moderation_record.admin).to be_admin
    end
  end
end
