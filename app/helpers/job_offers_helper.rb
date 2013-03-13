module JobOffersHelper

  def last_reply_time_for_job_offer(job)
    sorted_replies = job.designer_replies.sort {|x,y| x.created_at <=> y.created_at}
    sorted_replies.first.created_at
  end

  def last_reply_text_for_job_offer(job)
    if job.designer_replies.any?
      last_reply_time = last_reply_time_for_job_offer(job)
      "last reply #{time_ago_in_words(last_reply_time)} ago"
    else
      'no replies yet'
    end
  end

end