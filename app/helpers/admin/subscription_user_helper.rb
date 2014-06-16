module Admin
  module SubscriptionUserHelper
    def last_signed_in_mobile_at(last_sign_in_at)
      return 'n/a' unless last_sign_in_at
      time_ago_in_words(last_sign_in_at) + 'ago'
    end
  end
end
