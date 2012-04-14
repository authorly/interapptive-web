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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120413051618) do

  create_table "asset_maps", :force => true do |t|
    t.integer "asset_id"
    t.string  "assetable_type"
    t.integer "assetable_id"
  end

  add_index "asset_maps", ["asset_id", "assetable_id"], :name => "index_asset_maps_on_asset_id_and_assetable_id", :unique => true
  add_index "asset_maps", ["asset_id"], :name => "index_asset_maps_on_asset_id"
  add_index "asset_maps", ["assetable_id"], :name => "index_asset_maps_on_assetable_id"

  create_table "assets", :force => true do |t|
    t.string   "type"
    t.string   "image"
    t.string   "video"
    t.string   "audio"
    t.string   "font"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "assets", ["type"], :name => "index_assets_on_type"

  create_table "keyframes", :force => true do |t|
    t.integer  "scene_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "keyframes", ["scene_id"], :name => "index_keyframes_on_scene_id"

  create_table "scenes", :force => true do |t|
    t.integer  "storybook_id"
    t.integer  "audio_id"
    t.integer  "image_id"
    t.integer  "page_number"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "scenes", ["storybook_id"], :name => "index_scenes_on_storybook_id"

  create_table "storybooks", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "storybooks", ["user_id"], :name => "index_storybooks_on_user_id"

  create_table "touch_zones", :force => true do |t|
    t.integer  "scene_id"
    t.integer  "origin_x"
    t.integer  "origin_y"
    t.integer  "radius"
    t.integer  "video_id"
    t.integer  "audio_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "touch_zones", ["scene_id"], :name => "index_touch_zones_on_scene_id"

  create_table "users", :force => true do |t|
    t.string   "email",                  :null => false
    t.string   "username"
    t.string   "permalink"
    t.string   "password_digest",        :null => false
    t.string   "auth_token"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
