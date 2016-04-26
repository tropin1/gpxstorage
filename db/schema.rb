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

ActiveRecord::Schema.define(version: 20160420090716) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"
  enable_extension "unaccent"

  create_table "objects", force: :cascade do |t|
    t.tsvector "txt_index"
    t.string   "type",       limit: 50,                                                 null: false
    t.datetime "created_at",            default: -> { "timezone('UTC'::text, now())" }, null: false
    t.datetime "updated_at",            default: -> { "timezone('UTC'::text, now())" }, null: false
  end

  add_index "objects", ["txt_index"], name: "index_objects_on_txt_index", using: :gin
  add_index "objects", ["type"], name: "index_objects_on_type", using: :btree

  create_table "users", id: :integer, default: -> { "nextval('objects_id_seq'::regclass)" }, force: :cascade do |t|
    t.tsvector "txt_index"
    t.string   "type",                limit: 50,  default: "User",                                null: false
    t.datetime "created_at",                      default: -> { "timezone('UTC'::text, now())" }, null: false
    t.datetime "updated_at",                      default: -> { "timezone('UTC'::text, now())" }, null: false
    t.string   "name",                limit: 255,                                                 null: false
    t.string   "email",                           default: "",                                    null: false
    t.string   "encrypted_password",              default: "",                                    null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                   default: 0,                                     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "provider",            limit: 100
    t.string   "uid",                 limit: 150
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["name"], name: "index_users_on_name", using: :btree
  add_index "users", ["txt_index"], name: "index_users_on_txt_index", using: :gin
  add_index "users", ["type"], name: "index_users_on_type", using: :btree

end
