class SiteController < ApplicationController

  def home
    @featured_designers = Designer.featured_designers(3)
    render layout: 'home_layout'
  end

  def learn_more
    track_event("Viewing Learn More")
  end

  def account
  end

  def markdown
    render layout: false
  end

  def estimate
    # render layout: 'estimate_layout'
  end

end