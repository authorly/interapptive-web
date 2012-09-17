class Storybook < ActiveRecord::Base
  belongs_to :user
  has_many :scenes, :dependent => :destroy
  has_many :images, :through => :scenes,:dependent => :destroy
  has_many :sounds, :through => :scenes, :dependent => :destroy
  has_many :videos, :through => :scenes, :dependent => :destroy
  has_many :fonts, :through => :scenes, :dependent => :destroy

  has_one  :default_font, :through => :storybook_settings, :source => :font

  after_create :create_scene

  validates_presence_of :title

  private

    def create_scene
      self.scenes.create
    end
end
