class User < ActiveRecord::Base
  has_secure_password

  validates :password, :length => { :minimum => 6 }, 
            :on => :create

  validates :password, :length => { :minimum => 6 }, 
            :on => :update,
            :if => :password_digest_changed?

  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_uniqueness_of :email, :case_sensitive => false, :message => 'is in use.'
  validates_presence_of :email

  before_create { generate_token(:auth_token) }

  has_many :storybooks
  has_many :fonts, :through => :storybooks

  ROLES = %w( user developer admin )

  def admin?() role == 'admin' end

  def developer?() role == 'developer' end

  def backbone_response
    {
        'id'                       => id,
        'email'                    => email,
        'is_admin'                 => is_admin,
        'allowed_storybooks_count' => allowed_storybooks_count,
        'storybooks_count'         => storybooks.count,
        'created_at'               => created_at
    }
  end

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

  def save_by_admin
    pass = SecureRandom.base64(32).gsub(/[=+$\/]/, '').first(9)
    self.password = pass
    self.password_confirmation = pass
    if save
      Resque.enqueue(MailerQueue, 'UserMailer', 'password_creation_by_admin_notification', @user.id, pass)
      return true
    end
  end
end
