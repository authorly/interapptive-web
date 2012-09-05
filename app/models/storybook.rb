class Storybook < ActiveRecord::Base
  belongs_to :user
  has_many :scenes
  has_many :images, :through => :scenes
  has_many :sounds, :through => :scenes
  has_many :videos, :through => :scenes
  has_many :fonts, :through => :scenes

  has_one  :default_font, :through => :storybook_settings, :source => :font

  validates_presence_of :title
end
