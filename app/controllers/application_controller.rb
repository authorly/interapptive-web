require 'interapptive/helpers/authorization_helper'

class ApplicationController < ActionController::Base
  include Interapptive::Helpers::AuthorizationHelper

  protect_from_forgery
  before_filter :authorize
  helper_method :current_user, :signed_in?, :signed_in_as_user,
                :sort_column,  :sort_direction

  private

  def current_user
    @current_user ||= User.find_by_auth_token!(cookies[:auth_token]) if cookies[:auth_token]
  end

  def set_signed_in_as_user
    if params[:reset_user].present?
      cookies.delete(:signed_in_as_user_id)
    else
      if current_user.is_admin? && params[:signed_in_as_user_id].present?
        cookies.permanent[:signed_in_as_user_id] = params[:signed_in_as_user_id]
      end
    end
  end

  def signed_in_as_user
    if current_user.is_admin? && cookies[:signed_in_as_user_id].present?
      @signed_in_as_user ||= User.find_by_id(cookies[:signed_in_as_user_id])
    end

    @signed_in_as_user || current_user
  end

  def signed_in?
    true if current_user
  end

  def authorize
    redirect_to sign_in_path, :alert => "Please sign in to continue." unless signed_in?
  end

  def sign_out_if_deleted
    if current_user.is_deleted?
      cookies.delete :auth_token
      cookies.delete :is_admin
      cookies.delete :signed_in_as_user_id
      cookies.delete :km_aliased
      redirect_to sign_in_path, :alert => "Please sign in to continue."
    end
  end

  def cookie_domain
    return '.authorly.com'     if Rails.env == 'production'
    return '.interapptive.com' if %w(development test).include?(Rails.env)
  end

  def sort_column(model, default)
    model.column_names.include?(params[:sort]) ? params[:sort] : default
  end

  def sort_direction
    %w[ASC DESC].include?(params[:direction]) ? params[:direction] : "DESC"
  end
end
