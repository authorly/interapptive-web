class ChangeDefaultKeyframeTextColorToBlack < ActiveRecord::Migration
  def up
    change_column :scenes, :font_color, :string, :default => 'rgb(0, 0, 0)'
  end

  def down
    change_column :scenes, :font_color, :string, :default => 'rgb(255, 0, 0)'
  end
end
