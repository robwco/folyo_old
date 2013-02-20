class GuidesController < ApplicationController

  layout 'guide_layout'

  def how_to_pick_a_designer
    redirect_to "/guides/how_to_pick_a_great_designer"
  end

end