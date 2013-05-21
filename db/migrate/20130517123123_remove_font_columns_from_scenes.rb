class RemoveFontColumnsFromScenes < ActiveRecord::Migration
  def rgb_hash
    {
        'r' => 255,
        'g' => 0,
        'b' => 0
    }
  end

  def up
    change_table(:scenes) do |t|
      t.remove :font_face, :font_size, :font_color
    end
  end

  def down
    change_table(:scenes) do |t|
      t.column :font_color, :string, :default => rgb_hash
      t.column :font_face,  :string, :default => 'Arial'
      t.column :font_size,  :string, :default => '25'
    end
  end
end
