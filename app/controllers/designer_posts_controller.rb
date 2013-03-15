class DesignerPostsController < ApplicationController

  inherit_resources

  load_and_authorize_resource

  def update
    update! {designer_posts_path}
  end

  def create
    @designer_post = current_user.designer.designer_posts.build(params[:designer_post])
    track_event("New Designer Post")
    current_user.track_user_action("New Designer Post")
    create! {designer_posts_path}
  end

  protected

  def designer
    @designer ||= if current_user.is_a?(Admin)
       Designer.find(params[:designer_id])
    elsif current_user.is_a?(Designer)
      current_user
    else
      nil
    end
  end

  def collection
    @designer_posts = if current_user.is_a?(Admin) || current_user.is_a?(Designer)
      designer.posts
    else
      DesignerPost.all
    end
    @designer_posts = @designer_posts.page(params[:page]).per(10).ordered
  end

end