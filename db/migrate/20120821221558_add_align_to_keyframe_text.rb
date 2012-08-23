class AddAlignToKeyframeText < ActiveRecord::Migration
  def change
    add_column :keyframe_texts, :align, :string
  end
end
