class AddSyncOrderToKeyframeText < ActiveRecord::Migration
  def change
    add_column :keyframe_texts, :sync_order, :integer, :default => 1
  end
end
