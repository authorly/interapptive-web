class ApplicationController < ActionController::Base
  include UserSessionsHelper
  helper UserSessionsHelper

  protect_from_forgery
  # force_ssl unless Rails.env.test?

  private
    def current_user
      @current_user ||= User.find_by_auth_token!(cookies[:auth_token]) if cookies[:auth_token]
    end

    def signed_in?
      true if current_user
    end

    def authorize
      redirect_to sign_in_path, :alert => "Please sign in to continue." unless signed_in?
    end
end
