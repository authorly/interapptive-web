class Asset < ActiveRecord::Base
  has_many :asset_maps
  has_many :assetables, :through => :asset_maps
  has_many :scenes, :through => :asset_maps, :conditions => { :assetable_type => 'Scene' }

  # Easier than setting up the AR relation. Maybe?
  def storybook
    scenes.first.storybook
  end
end
