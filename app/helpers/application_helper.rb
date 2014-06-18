module ApplicationHelper
  def current_modal_title
    params[:from]
  end

  def yes_or_no(bool)
    return 'Yes' if bool
    'No'
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current sorting_#{sort_direction.downcase}" : nil
    direction = column == sort_column && sort_direction == 'ASC' ? "DESC" : "ASC"
    link_to title, { sort: column, direction: direction, q: params[:q] }, { class: css_class }
  end
end
