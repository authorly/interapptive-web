class Asset < ActiveRecord::Base
  has_many :asset_maps
  has_many :assetables, :through => :asset_maps
end
