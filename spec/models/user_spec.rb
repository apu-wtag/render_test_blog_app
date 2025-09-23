require 'rails_helper'

RSpec.describe User, type: :model do
  subject { create(:user) }
  describe "Validations" do
    # Presence validations
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:user_name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }

    # Uniqueness validations
    it { should validate_uniqueness_of(:user_name).case_insensitive }
    it { should validate_uniqueness_of(:email).case_insensitive }

    # Length validations
    it { should validate_length_of(:user_name).is_at_least(3) }
    it { should validate_length_of(:bio).is_at_most(500) }
    it { should validate_length_of(:password).is_at_least(8) }

    # Format validations
    it { should allow_value("valid_username").for(:user_name) }
    it { should_not allow_value("invalid username").for(:user_name).with_message("only allows letters, numbers, and underscores") }
    it { should allow_value("user@example.com").for(:email) }
    it { should_not allow_value("invalid-email").for(:email) }

    # has_secure_password matcher
    it { should have_secure_password }

    # Custom password complexity validation
    context "password complexity" do
      it "is valid with a complex password" do
        user = build(:user, password: "Password123!")
        expect(user).to be_valid
      end

      it "is invalid without a lowercase letter" do
        user = build(:user, password: "PASSWORD123!")
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("must include at least one lowercase letter")
      end

      it "is invalid without an uppercase letter" do
        user = build(:user, password: "password123!")
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("must include at least one uppercase letter")
      end

      it "is invalid without a digit" do
        user = build(:user, password: "Password!")
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("must include at least one digit")
      end

      it "is invalid without a special character" do
        user = build(:user, password: "Password123")
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("must include at least one special character i.e. (*, #, $ etc)")
      end
    end
  end
  describe "Associations" do
    it { should have_many(:articles).dependent(:destroy) }
    it { should have_many(:claps).dependent(:destroy) }
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_many(:reports).dependent(:destroy) }
    it { should have_many(:moderation_actions).class_name("ModerationRecord").with_foreign_key("admin_id").dependent(:nullify) }
    it { should have_one_attached(:profile_picture) }
  end

  describe "Roles" do
    it { should define_enum_for(:role).with_values(member: 0, editor: 1, admin: 2) }

    it "defaults to the 'member' role" do
      user = User.new
      expect(user.role).to eq("member")
    end
  end

  describe "Soft Deletion (Discard)" do
    let(:user) { create(:user) }
    let!(:article) { create(:article, user: user) }
    let!(:comment) { create(:comment, user: user) }

    context "when a user is discarded" do
      before do
        user.discard
      end

      it "discards their associated articles and comments" do
        expect(user.reload.discarded?).to be true
        expect(article.reload.discarded?).to be true
        expect(comment.reload.discarded?).to be true
      end
    end

    context "when a user is undiscarded" do
      before do
        user.discard
        user.undiscard
      end

      it "undiscards their associated articles and comments" do
        expect(user.reload.kept?).to be true
        expect(article.reload.kept?).to be true
        expect(comment.reload.kept?).to be true
      end
    end
  end

  describe "Custom Callbacks" do
    describe "#reject_if_banned" do
      let!(:discarded_user) { create(:user, :discarded, user_name: "banneduser", email: "banned@example.com") }

      it "prevents a new user from signing up with a banned username" do
        new_user = build(:user, user_name: "banneduser")
        expect(new_user).not_to be_valid
        expect(new_user.errors[:base]).to include("This account is banned. Please use another email/username.")
      end

      it "prevents a new user from signing up with a banned email" do
        new_user = build(:user, email: "banned@example.com")
        expect(new_user).not_to be_valid
        expect(new_user.errors[:base]).to include("This account is banned. Please use another email/username.")
      end
    end
  end
end
