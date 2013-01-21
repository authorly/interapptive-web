class Storybook < ActiveRecord::Base
  mount_uploader :icon, AppIconUploader
  mount_uploader :compiled_application, CompiledApplicationUploader

  belongs_to :user
  has_many :scenes, :dependent => :destroy

  has_many :images, :dependent => :destroy
  has_many :sounds, :dependent => :destroy
  has_many :videos, :dependent => :destroy
  has_many :fonts,  :dependent => :destroy

  has_one  :default_font, :through => :storybook_settings, :source => :font

  after_create :create_default_scene

  validates_presence_of :title

  def enqueue_for_compilation(json)
    # WA: TODO: Implement a storybook application JSON
    # verifier. Enqueue it for compilation only after
    # it is verified.
    Resque.enqueue(CompilationWorker, self.id, json)
  end

  private

  def create_default_scene
    scenes.create(is_main_menu: true)
    scenes.create(position: 0)
  end

end
