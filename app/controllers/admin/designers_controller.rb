class Admin::DesignersController < Admin::BaseController

  respond_to :html, :json

  section :designers

  def update
   update! do |format|
     format.json do
       @designer.featured_shot_url = params[:featured_shot_url] if params[:featured_shot_url]
       @designer.status = params[:status] if params[:status]
       @designer.rejection_message = params[:rejection_message] if params[:rejection_message]
       @designer.save
       render :json => @designer
     end
   end
  end

  def messages
    @designer_messages = Message.ordered.page(params[:page]).per(10)
  end

  def to_markdown
    @designer.to_markdown!
    redirect_to designer_path(@designer), notice: 'Successfully converted to markdown'
  end

  def accepted_email
    @designer = resource
    render "/designer_mailer/accepted_mail", layout: "mailer"
  end

  def rejected_email
    @designer = resource
    render "/designer_mailer/rejected_mail", layout: "mailer"
  end

  def show
    @designer = Designer.find(params[:id])
    render partial: 'designer_profile', locals: { designer: @designer, layout: false }
  end

  def pending
    @designers = Designer.pending.order_by(created_at: :asc)
  end

  protected

  def collection
    @designers = Designer.page(params[:page]).per(30).ordered_by_status
    unless params[:skill].blank?
      @designers = @designers.any_in(skills: params[:skill].to_sym)
    end
    unless params[:status].blank?
      @designers = @designers.where(status: params[:status].to_sym)
    end
  end

end
