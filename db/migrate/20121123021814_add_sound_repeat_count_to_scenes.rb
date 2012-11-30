class AddSoundRepeatCountToScenes < ActiveRecord::Migration
  def change
    add_column :scenes, :sound_repeat_count, 'SMALLINT UNSIGNED', :default => 0
  end
end
