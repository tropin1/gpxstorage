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

ActiveRecord::Schema.define(version: 20160516091327) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"
  enable_extension "unaccent"

  create_table "layers", id: :integer, default: -> { "nextval('objects_id_seq'::regclass)" }, force: :cascade do |t|
    t.tsvector "txt_index"
    t.string   "type",       limit: 50,  default: "Layer",                               null: false
    t.datetime "created_at",             default: -> { "timezone('UTC'::text, now())" }, null: false
    t.datetime "updated_at",             default: -> { "timezone('UTC'::text, now())" }, null: false
    t.string   "name",       limit: 50,                                                  null: false
    t.string   "url",        limit: 512,                                                 null: false
    t.boolean  "predefined",             default: false,                                 null: false
    t.index ["txt_index"], name: "index_layers_on_txt_index", using: :gin
    t.index ["type"], name: "index_layers_on_type", using: :btree
  end

  create_table "objects", force: :cascade do |t|
    t.tsvector "txt_index"
    t.string   "type",       limit: 50,                                                 null: false
    t.datetime "created_at",            default: -> { "timezone('UTC'::text, now())" }, null: false
    t.datetime "updated_at",            default: -> { "timezone('UTC'::text, now())" }, null: false
    t.index ["txt_index"], name: "index_objects_on_txt_index", using: :gin
    t.index ["type"], name: "index_objects_on_type", using: :btree
  end

  create_table "track_items", force: :cascade do |t|
    t.xml      "data",                                   null: false
    t.string   "color",      limit: 20,                  null: false
    t.string   "name",       limit: 255,                 null: false
    t.string   "track_code", limit: 52,                  null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.decimal  "len",                    default: "0.0", null: false
    t.index ["track_code"], name: "index_track_items_on_track_code", using: :btree
  end

  create_table "tracks", primary_key: "code", id: :string, limit: 52, force: :cascade do |t|
    t.integer  "id",                     default: -> { "nextval('objects_id_seq'::regclass)" }, null: false
    t.tsvector "txt_index"
    t.string   "type",       limit: 50,  default: "Track",                                      null: false
    t.datetime "created_at",             default: -> { "timezone('UTC'::text, now())" },        null: false
    t.datetime "updated_at",             default: -> { "timezone('UTC'::text, now())" },        null: false
    t.string   "name",       limit: 255,                                                        null: false
    t.integer  "user_id"
    t.text     "descr"
    t.boolean  "public",                 default: true,                                         null: false
    t.decimal  "len",                    default: "0.0",                                        null: false
    t.integer  "layer_id",               default: 1,                                            null: false
    t.index ["code"], name: "index_tracks_on_code", unique: true, using: :btree
    t.index ["layer_id"], name: "index_tracks_on_layer_id", using: :btree
    t.index ["txt_index"], name: "index_tracks_on_txt_index", using: :gin
    t.index ["type"], name: "index_tracks_on_type", using: :btree
    t.index ["user_id"], name: "index_tracks_on_user_id", using: :btree
  end

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
    t.boolean  "admin",                           default: false,                                 null: false
    t.integer  "cc",                              default: 0,                                     null: false
    t.integer  "following",                                                                                    array: true
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["following"], name: "index_users_on_following", using: :gin
    t.index ["name"], name: "index_users_on_name", using: :btree
    t.index ["txt_index"], name: "index_users_on_txt_index", using: :gin
    t.index ["type"], name: "index_users_on_type", using: :btree
  end

  add_foreign_key "track_items", "tracks", column: "track_code", primary_key: "code", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tracks", "layers", on_update: :cascade, on_delete: :restrict
  add_foreign_key "tracks", "users", on_update: :cascade, on_delete: :cascade
end
