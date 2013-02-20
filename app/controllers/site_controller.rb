class SiteController < ApplicationController

  def home
    @featured_designers = Designer.where(:pg_id.in => [184,120,265,62,10])
    render :layout => 'home_layout'
  end

  def learn_more
    # track_event("Viewing Learn More", {:mp_note => 'viewing learn more note'})
  end

end