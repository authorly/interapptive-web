class RenameAndCombineBoolsToString < ActiveRecord::Migration
  def change
    remove_column :storybooks, :build_ios
    remove_column :storybooks, :build_android
    remove_column :storybooks, :build_phone
    remove_column :storybooks, :build_tablet

    add_column :storybooks, :android_or_ios, :string, :default => "both"
    add_column :storybooks, :tablet_or_phone, :string, :default => "both"
  end
end