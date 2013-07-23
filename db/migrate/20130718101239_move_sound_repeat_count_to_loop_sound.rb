class MoveSoundRepeatCountToLoopSound < ActiveRecord::Migration
  def up
    change_table(:scenes) do |t|
      t.column :loop_sound, :boolean, default: false
      Scene.all.each{ |s| s.update_attribute(:loop_sound, s.sound_repeat_count == 0) }
      t.remove :sound_repeat_count
    end
  end

  def down
    change_table(:scenes) do |t|
      t.column  :sound_repeat_count, :integer, limit: 2, default: 0
      Scene.all.each{ |s| s.update_attribute(:sound_repeat_count, s.loop_sound ? 0 : 1) }
      t.remove :loop_sound
    end
  end
end
