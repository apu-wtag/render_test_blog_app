require 'rails_helper'

RSpec.describe ArticleBlobLink, type: :model do
  describe "Associations" do
    it { should belong_to(:article) }

    it { should belong_to(:blob).class_name("ActiveStorage::Blob").with_foreign_key("active_storage_blob_id") }
  end
end
