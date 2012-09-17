class Asset < ActiveRecord::Base
  has_many :asset_maps, :dependent => :destroy
  
  has_many :scenes, :through => :asset_maps, :source => :assetable,
                    :source_type => 'Scene',
                    :dependent => :destroy
end
