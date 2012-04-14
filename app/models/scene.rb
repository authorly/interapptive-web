class Scene < ActiveRecord::Base
  belongs_to :storybook
  has_many :keyframes
  has_many :asset_maps, :as => :assetable
  has_many :images, :through => :asset_maps, :source => :asset,
                    :conditions => { :type => 'Image' }
  has_many :sounds, :through => :asset_maps, :source => :asset,
                    :conditions => { :type => 'Sound' }
  has_many :action_groups
  has_many :actions, :through => :action_groups
  has_one :scene_settings
end
