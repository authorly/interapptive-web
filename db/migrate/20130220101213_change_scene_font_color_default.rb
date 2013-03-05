class ChangeSceneFontColorDefault < ActiveRecord::Migration
  def rgb_hash
    {
        'r' => 255,
        'g' => 0,
        'b' => 0
    }
  end

  def up
    if Scene.table_exists?
      change_column :scenes, :font_color, :string, :default => rgb_hash
    end
  end

  def down
    # Haha Nothing to do. Seriously?
  end
end
