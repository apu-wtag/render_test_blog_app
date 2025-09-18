class AddDiscardedAtToComments < ActiveRecord::Migration[8.0]
  def change
    add_column :comments, :discarded_at, :datetime
    add_index :comments, :discarded_at
  end
end
