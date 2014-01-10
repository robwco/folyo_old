class ProfilePicturesController < ApplicationController

  inherit_resources

  defaults singleton: true
  belongs_to :designer

  include Paperclipable::Controller

  protected

  def resource_name
    'profile picture'
  end
  helper_method :resource_name

end