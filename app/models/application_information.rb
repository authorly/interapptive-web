class ApplicationInformation < ActiveRecord::Base
  belongs_to :storybook

  mount_uploader :icon, AppIconUploader

  serialize :content_description

  validates :icon,                presence: true

  validates :available_from,      presence: true
  validates_each :available_from do |record, attr, value|
    if value.present?
      record.errors.add(attr, 'must be in the future') if value < Date.today
    end
  end

  validates :price_tier,          presence: true, inclusion: { in: (1..15).map{|i| "tier_#{i}" }}

  validates :description,         presence: true, length: { maximum: 4000 }

  validates :keywords,            presence: true, length: { maximum: 100 }

  validates :content_description, presence: true
  validates_each :content_description do |record, attr, value|
    if value.present?
      keys = [:fantasy_violence, :realistic_violence, :sexual_content, :profanity,
          :drugs, :mature, :gambling, :horror, :prolonged_violence,
          :graphical_sexual_content]
      keys.each do |key|
        record.errors.add(attr, "must contain #{key}") unless value[key].present?
      end
      record.errors.add(attr, "contains unexpected keys") if (value.keys - keys).length > 0
      record.errors.add(attr, "contains unexpected values") if (value.values - ['none', 'mild', 'intense']).length > 0
    end
  end


  def icon_image_id=(image_id)
    image = storybook.images.find(image_id)
    self.icon = image.image
    store_icon!
  end

end
