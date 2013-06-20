class AddVoiceoverIdToKeyframes < ActiveRecord::Migration
  def up
    change_table(:keyframes) do |t|
      t.remove :audio
      t.column :voiceover_id, :integer
      t.index  :voiceover_id
    end
  end

  def down
    change_table(:keyframes) do |t|
      t.column :audio, :string
      t.remove :voiceover_id
    end
  end
end
