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
  before_create :generate_kissmetrics_identifier

  has_many :storybooks, :dependent => :destroy
  has_many :fonts, :through => :storybooks

  def backbone_response
    {
        'id'                       => id,
        'email'                    => email,
        'is_admin'                 => is_admin,
        'allowed_storybooks_count' => allowed_storybooks_count,
        'storybooks_count'         => storybooks.count,
        'created_at'               => created_at,
        'company'                  => company,
        'name'                     => name
    }
  end

  def confirm
    return true if confirmed?
    # It should be noted that validations are skipped with ActiveRecord::Base#update_attribute
    # because of which we do not get any errors on password of the user despite validations
    # in place.
    self.update_attribute(:confirmed, true)
  end

  def generate_token(column)
    self[column] = unique_token_for(column)
  end

  def unique_token_for(column)
    begin
      token = SecureRandom.urlsafe_base64
    end while User.exists?(column => token)
    token
  end

  def generate_kissmetrics_identifier
    generate_token(:kissmetrics_identifier) if kissmetrics_identifier.blank?
  end

  def send_password_reset
    generate_token :password_reset_token
    self.password_reset_sent_at = Time.zone.now
    save!
    Resque.enqueue(MailerQueue, 'UserMailer', 'password_reset', self.id)
  end

  def reset_password
    pass = SecureRandom.base64(32).gsub(/[=+$\/]/, '').first(9)
    self.password = pass
    self.password_confirmation = pass
    if save
      Resque.enqueue(MailerQueue, 'UserMailer', 'password_reset_notification', self.id, pass)
      return true
    end
  end
end
