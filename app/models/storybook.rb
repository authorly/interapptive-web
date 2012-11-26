class Storybook < ActiveRecord::Base
  mount_uploader :compiled_application, CompiledApplicationUploader

  belongs_to :user
  has_many :scenes, :dependent => :destroy

  has_many :images, :dependent => :destroy
  has_many :sounds, :dependent => :destroy
  has_many :videos, :dependent => :destroy
  has_many :fonts,  :dependent => :destroy

  has_one  :default_font, :through => :storybook_settings, :source => :font

  after_create :create_scene

  validates_presence_of :title

  def enqueue_for_compilation(json)
    Resque.enqueue(CompilationQueue, self.id, json)
  end

  private

  def create_scene
    self.scenes.create
  end
end
