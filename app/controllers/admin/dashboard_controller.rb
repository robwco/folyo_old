class Admin::DashboardController < ApplicationController

  section :dashboard

  before_filter :check_admin_access

  def show
    @year = (params[:year] || Date.today.year).to_i
    @month = (params[:month] || Date.today.month).to_i

    @start_date = DateTime.new(@year, @month)
    @end_date = DateTime.new(@year, @month, -1, -1, -1, -1)

    @new_job_offer =  JobOffer.between(submited_at: @start_date..@end_date)
    @paid_job_offer = JobOffer.between(paid_at: @start_date..@end_date)
    @refunded_job_offer = JobOffer.between(refunded_at: @start_date..@end_date)

    @revenue = @paid_job_offer.map{|offer| offer.order.try(:total)}.compact.sum
    @revenue -= @refunded_job_offer.map{|offer| offer.order.try(:total)}.compact.sum

    replied_offers = JobOffer.elem_match(designer_replies: {created_at: {'$gte' => @start_date, '$lte' => @end_date}})
    @designer_replies_count = replied_offers.map{|offer| offer.designer_replies.between(created_at: @start_date..@end_date).count}.sum
    @picked_designer_replies_count = replied_offers.map{|offer| offer.designer_replies.between(updated_at: @start_date..@end_date).where(picked: true).count}.sum

    @new_designers = Designer.accepted.between(created_at: @start_date..@end_date)
    @new_clients = Client.between(created_at: @start_date..@end_date)
    @new_posts = DesignerPost.between(created_at: @start_date..@end_date)
  end

end