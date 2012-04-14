class Storybook < ActiveRecord::Base
  belongs_to :user
  has_many :scenes
  has_many :images, :through => :scenes
  has_many :sounds, :through => :scenes
  has_one  :storybook_settings
end
