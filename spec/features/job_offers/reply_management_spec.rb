require 'spec_helper'

feature 'Reply management', devise: true, js: true do

  given(:client) { FactoryGirl.create :client }
  given(:offer)  { FactoryGirl.create :job_offer, client: client }

  context 'with no reply' do

    background do
      login_as(client)
      visit offer_path(offer)
      click_link 'Designer Replies'
    end

    scenario "it display no replies" do
      page.should have_content "Sorry, you haven't received any replies yet"
    end

  end

  context 'with 3 new replies' do

    given(:n) { 3 }
    given!(:replies) { n.times.map { |i| FactoryGirl.create(:designer_reply, job_offer: offer, message: "a sample designer reply message #{i}") }}

    background do
      login_as(client)
      visit offer_path(offer)
      click_link 'Designer Replies'
    end

    scenario 'browse all replies' do
      page.should have_selector('a.reply', count: n)
      first('a.reply').click

      page.should have_content replies[2].message
      find(reply_navigation_button('next')).trigger('click')
      page.should have_content replies[1].message
      find(reply_navigation_button('next')).trigger('click')
      page.should have_content replies[0].message
      page.should have_no_selector(reply_navigation_button('next'))

      find(reply_navigation_button('prev')).trigger('click')
      page.should have_content replies[1].message
      find(reply_navigation_button('prev')).trigger('click')
      page.should have_content replies[2].message
      page.should have_no_selector(reply_navigation_button('prev'))

      find('h1 a.back').click
      page.should have_selector('a.reply', count: n)
    end

    scenario 'shortlist 2 replies and hide 1' do
      page.should have_selector('a.reply', count: n)
      page.find(reply_counter('shortlisted')).should have_content(0)
      page.find(reply_counter('hidden')).should have_content(0)
      page.find(reply_counter('new')).should have_content(n)
      page.find(reply_counter('all')).should have_content(n)
      first('a.reply').click

      find(reply_action_button('shortlist')).trigger('click')
      find(reply_navigation_button('next')).trigger('click')
      find(reply_action_button('shortlist')).trigger('click')
      find(reply_navigation_button('next')).trigger('click')
      find(reply_action_button('hide')).trigger('click')
      sleep(0.5)

      find('h1 a.back').click
      page.find(reply_counter('shortlisted')).should have_content(2)
      page.find(reply_counter('hidden')).should have_content(1)
      page.find(reply_counter('new')).should have_content(0)
      page.find(reply_counter('all')).should have_content(n)
    end

  end

  def reply_counter(kind)
    ".filter-#{kind} .count"
  end

  def reply_navigation_button(direction)
    ".subheader-pagination .#{direction}"
  end

  def reply_action_button(action)
    ".reply-actions .#{action}"
  end

end
