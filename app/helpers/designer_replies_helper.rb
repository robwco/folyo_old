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
      'active'
    elsif params[:status] == filter
      'active'
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

end