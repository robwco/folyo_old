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
       next_designer = ::Designer.pending.order_by(applied_at: :asc).where(:applied_at.gte => @designer.applied_at).first
       render json: { designer_count: ::Designer.pending.count, next_designer_path: admin_designer_path(next_designer) }
     end
   end
  end

  def messages
    @designer_messages = Message.ordered.page(params[:page]).per(10)
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
    show! do |format|
      format.html do
        if request.xhr?
          render partial: 'pending_designer', locals: { designer: @designer, layout: false }
        else
          @designers = Designer.pending.order_by(applied_at: :asc)
          render 'pending'
        end
      end
    end
  end

  def pending
    @designers = Designer.pending.order_by(applied_at: :asc)
    @designer = @designers.first
  end

  def profile
    @designer = resource
  end

  def reject
    @designer = resource
    render layout: false
  end

  def dribbble_profile
    show! do |format|
      format.html do
        @dribbble_shots = Dribbble::Player.find(@designer.dribbble_username).shots
      end
    end
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
