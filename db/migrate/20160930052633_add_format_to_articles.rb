class AddFormatToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :format, :string
  end
end
