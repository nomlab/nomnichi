class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.integer :user_id
      t.string :title
      t.string :perma_link
      t.text :content
      t.datetime :published_on
      t.boolean :approved
      t.integer :count
      t.boolean :promote_headline

      t.timestamps null: false
    end
  end
end
