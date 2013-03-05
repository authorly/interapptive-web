class RemoveKeyframeTexts < ActiveRecord::Migration
  class KeyframeText < ActiveRecord::Base
    belongs_to :keyframe

    def self.convert_to_widget
      max_widget_id = find_max_widget_id

      find_each do |kft|
        keyframe = kft.keyframe
        keyframe.widgets ||= []
        keyframe.widgets << kft.widget_hash(max_widget_id + 1)
        if keyframe.save(:validate => false)
          max_widget_id += 1
        end
      end
    end

    def self.find_max_widget_id
      (Keyframe.all.collect(&:widgets).flatten + Scene.all.collect(&:widgets).flatten).
        collect do |f|
        f['id'].to_i
        end.max
    end

    def widget_hash(widget_id)
      {
        'id'                  => widget_id,
        'type'                => 'TextWidget',
        'retention'           => 'keyframe',
        'retentionMutability' => false,
        'string'              => content,
        'sync_order'          => sync_order,
        'position'            => { 'x' => x_coord, 'y' => y_coord },
        'left'                => x_coord,
        'bottom'              => y_coord
      }
    end
  end

  def up
    if KeyframeText.table_exists?
      KeyframeText.convert_to_widget
      drop_table KeyframeText.table_name
    end
  end

  def down
    # Haha Nothing to do. Seriously?
  end
end
