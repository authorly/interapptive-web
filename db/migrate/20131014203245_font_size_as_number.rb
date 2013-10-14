class FontSizeAsNumber < ActiveRecord::Migration
  def up
    Keyframe.find_each do |keyframe|
      widgets = (keyframe.widgets || []).select{|w| w["type"] == 'TextWidget' }
      if widgets.present?
        widgets.each{|w| w['font_size'] = w['font_size'].to_i }
        keyframe.save(validate: false)
      end
    end
  end

  def down
    Keyframe.find_each do |keyframe|
      widgets = (keyframe.widgets || []).select{|w| w["type"] == 'TextWidget' }
      if widgets.present?
        widgets.each{|w| w['font_size'] = w['font_size'].to_s }
        keyframe.save(validate: false)
      end
    end
  end
end
