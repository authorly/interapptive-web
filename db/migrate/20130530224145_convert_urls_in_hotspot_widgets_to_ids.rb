class ConvertUrlsInHotspotWidgetsToIds < ActiveRecord::Migration
  def up
    Scene.find_each do |scene|
      scene_widgets = scene.widgets.clone
      scene.widgets.each_with_index do |widget, index|
        if widget['type'] = 'HotspotWidget'
          key = nil
          if widget['sound_id']
            key = 'sound_id'
          elsif widget['video_id']
            key = 'video_id'
          end

          if key
            scene_widgets[index][key] = File.basename(File.dirname(widget[key]))
          end
        end
      end

      scene.widgets = scene_widgets
      scene.save(:validate => false)
    end
  end

  def down
    # Haha Nothing to do. Seriously?
  end
end
