class PublishRequest < ActiveRecord::Base
  belongs_to :storybook
  has_many :applications

  def done?
    applications_count < [:itunes, :google_play, :amazon].count
  end

  def as_json(options={})
    super({
      include: :applications,
    }.merge(options))
  end
end
