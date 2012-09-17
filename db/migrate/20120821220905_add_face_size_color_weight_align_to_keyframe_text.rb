class AddFaceSizeColorWeightAlignToKeyframeText < ActiveRecord::Migration
  def change
    
    add_column :keyframe_texts, :weight, :string

  end
end
