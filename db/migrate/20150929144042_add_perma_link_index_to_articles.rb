class AddPermaLinkIndexToArticles < ActiveRecord::Migration
  def change
    add_index :articles, :perma_link, unique: true
  end
end
