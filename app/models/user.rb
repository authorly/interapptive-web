class User < ActiveRecord::Base
  has_secure_password

  validates_length_of :password, :minimum => 6, :on => :create

  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_uniqueness_of :email, :case_sensitive => false, :message => 'is in use.'
  validates_presence_of :email

  validates_uniqueness_of :username

  before_create { generate_token(:auth_token) }

  has_many :storybooks
  has_many :actions # TODO: sure about this?

  ROLES = %w( user developer admin )

  def admin?() role == 'admin' end

  def developer?() role == 'developer' end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  def send_password_reset
    generate_token :password_reset_token
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver
  end

end
