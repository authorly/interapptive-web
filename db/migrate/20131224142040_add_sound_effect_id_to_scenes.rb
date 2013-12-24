class AddSoundEffectIdToScenes < ActiveRecord::Migration
  def change
    add_column :scenes, :sound_effect_id, :integer
  end
end
