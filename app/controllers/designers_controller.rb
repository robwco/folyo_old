class DesignersController < ApplicationController

  inherit_resources
  load_and_authorize_resource except: :show_by_pg_id

  section :designers

  def show_by_pg_id
    @designer = Designer.where(designer_pg_id: params[:id].to_i).first
    raise Mongoid::Errors::DocumentNotFound.new(Designer, pg_id: params[:id].to_i) if @designer.nil?
    redirect_to designer_url(@designer), status: :moved_permanently
  end

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
