class Storybook < ActiveRecord::Base
  belongs_to :user
  has_many :scenes, :dependent => :destroy

  has_many :images, :dependent => :destroy
  has_many :sounds, :dependent => :destroy
  has_many :videos, :dependent => :destroy
  has_many :fonts,  :dependent => :destroy

  has_one  :default_font, :through => :storybook_settings, :source => :font

  after_create :create_default_scenes

  validates_presence_of :title

  private

  def create_default_scenes
    scenes.create(is_main_menu: true)
    scenes.create(position: 0)
  end
end
