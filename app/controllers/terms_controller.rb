class TermsController < ApplicationController
  layout 'user_sessions'

  def new
    KMTS.record(current_user.email, "Visited privacy policy agreement page")
  end

  def create
    if params[:terms] == 'on'
      current_user.update_attribute(:accepted_terms, true)
      redirect_to storybooks_url
    else
      redirect_to new_term_url
    end
  end
end
