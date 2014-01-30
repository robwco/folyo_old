class SiteController < ApplicationController

  def home
    render :layout => 'home_layout'
  end

  def learn_more
    track_event("Viewing Learn More")
  end

  def markdown
    render layout: false
  end

end