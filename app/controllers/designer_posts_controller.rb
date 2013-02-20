class DesignerPostsController < ApplicationController

  inherit_resources

  before_filter :check_designer_access
  before_filter :set_designer

  load_and_authorize_resource

  actions :index, :show, :new, :create, :update, :edit

  def index
    @designer_posts = @designer.posts
  end

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

  def set_designer
    @designer = if current_user.is_a?(Admin)
       Designer.find(params[:designer_id])
    elsif current_user.is_a?(Designer)
      current_user
    else
      nil
    end
  end

end