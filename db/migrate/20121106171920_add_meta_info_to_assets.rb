class AddMetaInfoToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :meta_info,   :text
  end
end
