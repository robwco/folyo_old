module Paperclipable

  module Controller

    extend ActiveSupport::Concern

    included do

      custom_actions resource: [:crop, :update_crop, :status]
      respond_to :json,  only: [:create, :status]

      def show
        show! do |format|
          format.html { render partial: 'paperclipable/image' }
        end
      end

      def create
        params[resource_class.to_s.underscore] = params[:image]
        create! do |format|
          format.json { render json: {polling_path: status_resource_path(format: :json)} }
        end
      end

      def destroy
        destroy!(notice: "#{resource_name.capitalize} was successfully removed!") { parent_path }
      end

      def status
        status! do |format|
          format.json { render json: { status: resource.status, image_id: resource.id } }
        end
      end

      def crop
        crop! do |format|
          format.html { render 'paperclipable/crop', layout: false }
        end
      end

      def update_crop
        update_crop! do |format|
          resource.crop_cover(
            params[:image][:crop_x],
            params[:image][:crop_y],
            params[:image][:crop_w],
            params[:image][:crop_h]
          )
          format.html { redirect_to parent_path, notice: "#{resource_name.capitalize} is being cropped, please wait a few seconds." }
        end
      end

    end

  end

end