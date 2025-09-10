class CreateClaps < ActiveRecord::Migration[8.0]
  def change
    create_table :claps do |t|
      t.references :user, null: false, foreign_key: true
      t.references :article, null: false, foreign_key: true

      t.timestamps
    end
    add_index :claps, [:user_id, :article_id], unique: true
  end
end
