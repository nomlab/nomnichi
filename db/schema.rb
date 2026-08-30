# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160930052633) do

  create_table "articles", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "title"
    t.string   "perma_link"
    t.text     "content"
    t.datetime "published_on"
    t.boolean  "approved"
    t.integer  "count",            default: 0
    t.boolean  "promote_headline"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "format"
  end

  add_index "articles", ["perma_link"], name: "index_articles_on_perma_link", unique: true

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "body"
    t.integer  "article_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "ident"
    t.string   "password"
    t.string   "salt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "provider"
    t.string   "uid"
    t.string   "avatar_url"
  end

  add_index "users", ["ident"], name: "index_users_on_ident", unique: true

end
