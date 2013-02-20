class SerializeSceneFontColor < ActiveRecord::Migration
  class Scene < ActiveRecord::Base

    def self.serialize_font_color
      find_each do |s|
        s.font_color = s.rgb_hash
        s.save(:validate => false)
      end
    end

    def rgb_hash
      {
        'r' => 255,
        'g' => 0,
        'b' => 0
      }
    end
  end

  def up
    if Scene.table_exists?
      Scene.serialize_font_color
    end
  end

  def down
    # Haha Nothing to do. Seriously?
  end
end
