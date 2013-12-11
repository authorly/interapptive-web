class Application < ActiveRecord::Base
  belongs_to :publish_request, counter_cache: true
  PROVIDERS = {
    :itunes          => 'iTunes',
    :google_play     => 'Google Play',
    :amazon_appstore => 'Amazon Appstore',
  }

  validates :url, presence: true
  validates :provider, uniqueness: { scope: :publish_request_id },
    inclusion: { in: PROVIDERS.keys.map(&:to_s) }
end
