class CreateAssetMaps < ActiveRecord::Migration
  def change
    create_table :asset_maps do |t|
      t.references :asset
      t.string     :assetable_type
      t.integer    :assetable_id
    end

    add_index :asset_maps, :asset_id
    add_index :asset_maps, :assetable_id
    add_index :asset_maps, [:asset_id, :assetable_id], :unique => true
  end
end
