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

end