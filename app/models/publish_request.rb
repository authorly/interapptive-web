class PublishRequest < ActiveRecord::Base
  belongs_to :storybook
  has_many :applications
  accepts_nested_attributes_for :applications, reject_if: proc { |attributes| attributes['url'].blank? }

  def done?
    applications_count < [:itunes, :google_play, :amazon].count
  end

  def as_json(options={})
    super({
      include: :applications,
    }.merge(options))
  end
end
