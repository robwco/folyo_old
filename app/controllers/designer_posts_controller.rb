class DesignerPostsController < ApplicationController

  inherit_resources

  load_and_authorize_resource

  section :designer_posts

  def update
    update! {posts_path}
  end

  def create
    @designer_post = current_user.posts.build(params[:designer_post])
    create! {posts_path}
  end

  protected

  def designer
    @designer ||= if params[:designer_id]
       Designer.find(params[:designer_id])
    elsif current_user.is_a?(Designer)
      current_user
    else
      nil
    end
  end

  def collection
    @designer_posts = if designer
      designer.posts
    else
      DesignerPost.all
    end
    @designer_posts = @designer_posts.page(params[:page]).per(10).ordered
  end

end