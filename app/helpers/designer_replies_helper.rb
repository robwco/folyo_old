module DesignerRepliesHelper

  def class_for_reply(reply)
    if reply.shortlisted?
      'reply-shortlisted'
    elsif reply.hidden?
      'reply-hidden'
    else
      ''
    end
  end

  def active_class_for_filter(filter = nil)
    if filter.nil? && params[:status].blank?
      'current'
    elsif params[:status] == filter
      'current'
    else
      ''
    end
  end

  def back_name_for_status(status)
    if status.blank?
      'New replies'
    elsif status == 'all'
      'All replies'
    elsif status == 'shortlisted'
      'Shortlist'
    elsif status == 'hidden'
      'Hidden replies'
    end
  end

  def shortlist_title(reply)
    if reply.shortlisted?
      'Remove from shortlist'
    else
      'Add the designer to my shortlist'
    end
  end

  def hide_title(reply)
    if reply.hidden?
      'Un-hide this designer'
    else
      'Hide this designer'
    end
  end

end
