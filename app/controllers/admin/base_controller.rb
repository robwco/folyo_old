class Admin::BaseController < ApplicationController

  inherit_resources

  before_filter :check_admin_access

  load_and_authorize_resource

end