class AddRememberExpiresAtToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :remember_expires_at, :datetime
  end
end
