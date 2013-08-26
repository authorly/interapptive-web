module ApplicationHelper
  def current_modal_title
    params[:from]
  end

  def yes_or_no(bool)
    return 'Yes' if bool
    'No'
  end
end
