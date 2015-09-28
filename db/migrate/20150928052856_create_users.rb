class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :ident
      t.string :password
      t.string :salt

      t.timestamps null: false
    end
    add_index :users, :ident, unique: true
  end
end
