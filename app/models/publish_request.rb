class PublishRequest < ActiveRecord::Base
  belongs_to :storybook
  has_many :applications

  def done?
    applications_count < [:itunes, :google_play, :amazon].count
  end
end
