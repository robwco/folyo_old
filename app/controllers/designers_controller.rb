class DesignersController < ApplicationController

  inherit_resources
  #before_filter :check_user_access
  #load_and_authorize_resource

  layout 'carrousel'

  def index
    @search = DesignerSearch.create(user: current_user, public_only: current_user.nil?)
    @designer = @search.sample
  end

  def show
    #track_event("Viewing Designer", {:mp_note => 'Viewing profile for '+@designer.user.full_name, :name => @designer.user.full_name, "$bucket" => @designer.user.email})
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
