class ApplicationInformation < ActiveRecord::Base
  belongs_to :storybook

  belongs_to :large_icon, class_name: 'Image'

  serialize :retina_3_5_screenshot_ids,  Array
  serialize :retina_4_0_screenshot_ids,  Array
  serialize :retina_ipad_screenshot_ids, Array

  serialize :content_description

  before_validation :sanitize_screenshots

  validate :large_icon,           presence: true
  validates_each :retina_3_5_screenshot_ids, :retina_4_0_screenshot_ids, :retina_ipad_screenshot_ids do |record, attr, value|
     if (value||[]).length < 2
       record.errors.add(attr, 'please add at least 2 screenshots')
     end
     if (value||[]).length > 5
       record.errors.add(attr, 'please add at most 5 screenshots')
     end
  end

  validates :available_from,      presence: true
  validates_each :available_from do |record, attr, value|
    if value.present?
      record.errors.add(attr, 'must be in the future') if value < Date.today
    end
  end

  validates :price_tier,          presence: true, inclusion: { in: (1..15).map{|i| "tier_#{i}" }}

  validates :description,         presence: true, length: { maximum: 4000 }

  validates :keywords,            presence: true, length: { maximum: 100 }

  validates_each :content_description do |record, attr, value|
    value = {} unless value.present?
    labels = {
      'fantasy_violence' =>        'Cartoon or Fantasy Violence',
      'realistic_violence' =>      'Realistic Violence',
      'sexual_content' =>          'Sexual Content or Nudity',
      'profanity' =>               'Profanity or Crude Humor',
      'drugs' =>                   'Alcohol, Tobacco, or Drug Use or References',
      'mature' =>                  'MatureSuggestive Themes',
      'gambling' =>                'Simulated Gambling',
      'horror' =>                  'HorrorFear Themes',
      'prolonged_violence' =>      'Prolonged Graphic or Sadistic Realistic Violence',
      'graphical_sexual_content' =>'Graphical Sexual Content and Nudity',
    }

    missing = labels.keys.reject{ |key| value[key].present? }
    if missing.length > 0
      record.errors.add(attr, "Please select a content description for the following section(s): #{missing.map{|key| labels[key]}.join(', ')}")
    end
    record.errors.add(attr, "contains unexpected keys") if (value.keys - labels.keys).length > 0
    record.errors.add(attr, "contains unexpected values") if (value.values - ['none', 'mild', 'intense']).length > 0
  end

  def sanitize_screenshots
    [:retina_3_5_screenshot_ids, :retina_4_0_screenshot_ids, :retina_ipad_screenshot_ids].each do |key|
      self[key] = (self[key] || []).map{|id| Image.where(id: id).first}.compact.uniq.map(&:id)
    end

  end

end



