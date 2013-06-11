class CreateSchema < ActiveRecord::Migration
  def up
    create_table "assets" do |t|
      t.string   "type"
      t.string   "image"
      t.string   "video"
      t.string   "sound"
      t.string   "font"
      t.datetime "created_at",                         :null => false
      t.datetime "updated_at",                         :null => false
      t.integer  "storybook_id"
      t.boolean  "generated",    :default => false
      t.text     "meta_info"
      t.string   "asset_type",   :default => "custom"
    end
    add_index "assets", ["storybook_id", "type"]

    create_table "keyframes" do |t|
      t.integer  "scene_id"
      t.datetime "created_at",                                 :null => false
      t.datetime "updated_at",                                 :null => false
      t.integer  "preview_image_id"
      t.text     "widgets"
      t.integer  "position"
      t.string   "audio"
      t.text     "content_highlight_times"
      t.boolean  "is_animation",            :default => false
      t.float    "animation_duration",      :default => 3.0
    end
    add_index "keyframes", ["scene_id"]

    create_table "scenes" do |t|
      t.integer  "storybook_id"
      t.integer  "sound_id"
      t.integer  "position"
      t.datetime "created_at",                                         :null => false
      t.datetime "updated_at",                                         :null => false
      t.integer  "preview_image_id"
      t.integer  "sound_repeat_count", :limit => 2, :default => 0
      t.text     "widgets"
      t.boolean  "is_main_menu",                    :default => false
    end
    add_index "scenes", ["storybook_id"]

    create_table "storybooks" do |t|
      t.integer  "user_id"
      t.string   "title"
      t.datetime "created_at",                                         :null => false
      t.datetime "updated_at",                                         :null => false
      t.string   "author"
      t.text     "description"
      t.decimal  "price",                :precision => 8, :scale => 2
      t.string   "icon"
      t.string   "compiled_application"
      t.string   "android_application"
      t.text     "settings"
      t.text     "widgets"
    end
    add_index "storybooks", ["user_id"]

    create_table "users" do |t|
      t.string   "email",                                      :null => false
      t.string   "username"
      t.string   "role",                   :default => "user", :null => false
      t.string   "permalink"
      t.string   "password_digest",                            :null => false
      t.string   "auth_token"
      t.string   "password_reset_token"
      t.datetime "password_reset_sent_at"
      t.datetime "created_at",                                 :null => false
      t.datetime "updated_at",                                 :null => false
    end
    add_index "users", ["email"], :unique => true
  end

  def down
    drop_table :users
    drop_table :storybooks
    drop_table :scenes
    drop_table :keyframes
    drop_table :assets
  end
end
