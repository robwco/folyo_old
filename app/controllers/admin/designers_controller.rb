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

  def posts
    @designer_posts = DesignerPost.ordered.page(params[:page]).per(10)
  end

  def messages
    @designer_messages = Message.ordered.page(params[:page]).per(10)
  end

  def to_markdown
    @designer.to_markdown!
    redirect_to designer_path(@designer), notice: 'Successfully converted to markdown'
  end

  protected

  def collection
    @designers = Designer.page(params[:page]).per(10).ordered_by_status
    unless params[:skill].blank?
      @designers = @designers.any_in(skills: params[:skill].to_sym)
    end
    unless params[:status].blank?
      @designers = @designers.where(status: params[:status].to_sym)
    end
  end

end