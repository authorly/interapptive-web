class ApplicationController < ActionController::Base
  protect_from_forgery

  # TODO: Implement SSL on CI server! Also for VPS staging
  # force_ssl unless Rails.env.test?

  include UserSessionsHelper
  helper UserSessionsHelper
end
