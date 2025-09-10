class AddClapsCountToArticle < ActiveRecord::Migration[8.0]
  def change
    add_column :articles, :claps_count, :integer, default: 0, null: false
  end
end
