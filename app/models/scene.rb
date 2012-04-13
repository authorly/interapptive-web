class Scene < ActiveRecord::Base
  belongs_to :storybook
  has_many :keyframes
  has_many :asset_maps
  has_many :assets, :through => :asset_maps
  # TODO: has_many :images, has_many :sounds
end
