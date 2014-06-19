module Admin
  module SubscriptionUserHelper
    def last_signed_in_mobile_at(last_sign_in_at)
      return 'n/a' unless last_sign_in_at
      time_ago_in_words(last_sign_in_at) + ' ago'
    end

    def sign_up_time(date_time)
      return time_ago_in_words(date_time) + " ago" if date_time > 24.hours.ago
      date_time.to_s(:us)
    end
  end
end
