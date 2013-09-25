class ChangeScaleToHorizontalAndVertical < ActiveRecord::Migration
  def up
    Storybook.find_each do |storybook|
      storybook.widgets.select{|w| w['type'] == 'ButtonWidget' }.each do |widget|
        scale_to_horizontal_and_vertical(widget)
      end
      storybook.save(validate:false)
    end

    Scene.where(is_main_menu: true).find_each do |scene|
      scene.widgets.select{|w| w['type'] == 'ButtonWidget' }.each do |widget|
        scale_to_horizontal_and_vertical(widget)
      end
      scene.save(validate:false)
    end

    Keyframe.find_each do |keyframe|
      (keyframe.widgets || []).select{|w| w['type'] == 'SpriteOrientation' }.each do |widget|
        scale_to_horizontal_and_vertical(widget)
      end
      keyframe.save(validate:false)
    end
  end

  def down
    Storybook.find_each do |storybook|
      storybook.widgets.select{|w| w['type'] == 'ButtonWidget' }.each do |widget|
        horizontal_and_vertical_to_scale(widget)
      end
      storybook.save(validate:false)
    end

    Scene.where(is_main_menu: true).find_each do |scene|
      scene.widgets.select{|w| w['type'] == 'ButtonWidget' }.each do |widget|
        horizontal_and_vertical_to_scale(widget)
      end
      scene.save(validate:false)
    end

    Keyframe.find_each do |keyframe|
      (keyframe.widgets || []).select{|w| w['type'] == 'SpriteOrientation' }.each do |widget|
        horizontal_and_vertical_to_scale(widget)
      end
      keyframe.save(validate:false)
    end
  end

  protected

  def scale_to_horizontal_and_vertical(widget)
    widget['scale'] = {
      'horizontal' => (widget['scale'] * 100).to_i,
      'vertical'   => (widget['scale'] * 100).to_i,
    }
  end

  def horizontal_and_vertical_to_scale(widget)
    widget['scale'] = widget['scale']['horizontal'] * 0.01
  end

end
