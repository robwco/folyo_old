class DesignersController < ApplicationController

  inherit_resources
  load_and_authorize_resource

  def index
    @skill = params[:skill].try(:to_sym)
    index!
  end

  def map
    @designers = Designer.accepted.public_only.where(:coordinates.ne => nil)
  end

  def update
    update! { edit_designer_path(@designer) }
  end

  protected

  def collection
    @designers = Designer.page(params[:page]).per(10).ordered_by_status

    if current_user
      @designers = @designers.public_private
    else
      @designers = @designers.public_only
    end

    unless params[:skill].blank?
      @designers = @designers.any_in(skills: params[:skill].to_sym)
    end
  end

end
