class DesignersController < ApplicationController

  inherit_resources
  before_filter :check_user_access
  load_and_authorize_resource

  def index
    @search = DesignerSearch.create(user: current_user, public_only: current_user.nil?)
    @designer = @search.sample
    render layout: 'carrousel'
  end

  def update
    update! { edit_designer_path(@designer) }
  end

  protected

  def collection
    @designers = Designer.ordered.accepted.page(page).per(10)

    if current_user
      @designers = @designers.public_private
    else
      @designers = @designers.public_only
    end
  end

end
