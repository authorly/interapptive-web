class Storybook < ActiveRecord::Base
  mount_uploader :icon, AppIconUploader
  mount_uploader :compiled_application, IosApplicationUploader
  mount_uploader :android_application,  AndroidApplicationUploader

  belongs_to :user
  has_many :scenes, :dependent => :destroy

  has_many :images, :dependent => :destroy
  has_many :sounds, :dependent => :destroy
  has_many :videos, :dependent => :destroy
  has_many :fonts,  :dependent => :destroy

  has_one  :default_font, :through => :storybook_settings, :source => :font

  after_create :create_default_scene

  validates_presence_of :title

  def enqueue_for_compilation(platform, json)
    case platform
    when 'ios'
      enqueue_for_ios_compilation(json)
    when 'android'
      enqueue_for_android_compilation(json)
    end
  end

  def enqueue_for_ios_compilation(json)
    # WA: TODO: Implement a storybook application JSON
    # verifier. Enqueue it for compilation only after
    # it is verified.
    Resque.enqueue(IosCompilationQueue, self.id, json)
  end

  def enqueue_for_android_compilation(json)
    Resque.enqueue(AndroidCompilationQueue, self.id, json)
  end

  def owned_by?(other_user)
    other_user == user
  end

  def image_id=(image_id)
    image = images.find(image_id)
    self.remote_icon_url = image.image.url
  end

  private

  def create_default_scene
    scenes.create(is_main_menu: true)
    scenes.create(position: 0)
  end

end
