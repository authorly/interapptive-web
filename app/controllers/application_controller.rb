require 'interapptive/helpers/authorization_helper'

class ApplicationController < ActionController::Base
  include Interapptive::Helpers::AuthorizationHelper

  protect_from_forgery
  before_filter :authorize
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

  helper_method :current_user, :signed_in?
end
