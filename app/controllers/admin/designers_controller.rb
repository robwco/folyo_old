class Admin::DesignersController < Admin::BaseController

  respond_to :html, :json

  def update
   update! do |format|
     format.json do
       if params[:featured_shot_url]
         @designer.featured_shot_url = params[:featured_shot_url]
       end
       if params[:status]
         @designer.status = params[:status]
       end
       if params[:coordinates]
         @designer.coordinates = params[:coordinates]
        end
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

  protected

  def collection
    @designers = Designer.page(params[:page]).per(10).ordered_by_status
    unless params[:skill].blank?
      @designers = @designers.any_in(skills: params[:skill].to_sym)
    end
  end

end