class AddDefaultValuesToArticles < ActiveRecord::Migration
  def change
    change_column_default :articles, :count, 0
  end
end
