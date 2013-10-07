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

  serialize :widgets

  SETTINGS = {
    pageFlipTransitionDuration: 0.6,
    paragraphTextFadeDuration: 0.4,
    autoplayPageTurnDelay: 0.2,
    autoplayKeyframeDelay: 0.1,
  }
  serialize :settings, Hash

  before_validation :set_default_settings, on: :create
  before_create     :create_widgets
  after_create      :create_default_scene

  validate  :validate_allowed_storybooks_count, :before => :create
  validates :title, :presence => true, :uniqueness => { :scope => :user_id }

  SETTINGS.each do |setting, _|
    validates setting, numericality: { greater_than_or_equal_to: 0 }
  end

  def enqueue_for_compilation(platform, json, recipient)
    case platform
    when 'ios'
      enqueue_for_ios_compilation(json, recipient)
    when 'android'
      enqueue_for_android_compilation(json, recipient)
    end
  end

  def enqueue_for_ios_compilation(json, recipient)
    # WA: TODO: Implement a storybook application JSON
    # verifier. Enqueue it for compilation only after
    # it is verified.
    Resque.enqueue(IosCompilationQueue, self.id, json, recipient.email)
  end

  def enqueue_for_android_compilation(json, recipient)
    Resque.enqueue(AndroidCompilationQueue, self.id, json, recipient.email)
  end

  def owned_by?(other_user)
    other_user == user
  end

  def image_id=(image_id)
    image = images.find(image_id)
    self.icon = image.image
    store_icon!
  end

  SETTINGS.each do |setting, _|
    define_method(setting) do
      settings[setting]
    end

    define_method("#{setting}=") do |value|
      settings[setting] = value
    end
  end

  def as_json(options)
    super({except: :settings, methods: SETTINGS.keys}.merge(options)).merge({
      preview_image_url: scenes.where(is_main_menu: true)[0].try(:preview_image_url)
    })
  end

  private

  def create_default_scene
    scenes.create(is_main_menu: true)
    scenes.create(position: 0)
  end

  def set_default_settings
    SETTINGS.each do |setting, default|
      self.send("#{setting}=", self.send(setting) || default)
    end
  end

  def create_widgets
    # On the client side we need widgets to have unique id's.
    # The home button has id 1. The main menu buttons have id's 2, 3 & 4.
    # `z_order` is in the 4000+ range to leave [1..4000) for sprites,
    # [5000..6000) for hotspots and [6000...) for texts. Main menu buttons have
    # z_order wihtin [4000..4010)
    self.widgets = [
      {type: 'ButtonWidget', id: 1, name: 'home', z_order: 4010, scale: 1, position: {y: 400, x: 200} },
    ]
  end

  def validate_allowed_storybooks_count
    if self.user.storybooks.count >= self.user.allowed_storybooks_count
      errors[:base] << "You are not allowed to create any more storybooks."
    end
  end
end
