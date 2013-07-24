require 'spec_helper'

feature 'Moderate a job offer', devise: true do

  given(:client) { FactoryGirl.create(:client) }
  given(:order)  { FactoryGirl.build(:order) }

  background do
    login_as client
  end

  context 'when offer is waiting for review' do

    given!(:offer)  { FactoryGirl.create(:job_offer, status: :waiting_for_review, client: client, order: order) }

    scenario 'read project status' do
      visit offers_url
      assert_page_title 'My Offers'
      assert_offer_count 1

      page.should have_content 'Waiting for Review'
      click_link offer.title

      assert_active_nav_item 'Your Order'
      page.should have_content 'We are reviewing your project'
    end

  end

  context 'when offer is rejected' do

    given!(:offer)  { FactoryGirl.create(:job_offer, status: :rejected, review_comment: 'rejected', client: client, order: order) }

    scenario 'read project status' do
      expect {
        visit offers_url
        assert_page_title 'My Offers'
        assert_offer_count 1

        page.should have_content 'Needs Your Attention'
        click_link offer.title

        assert_active_nav_item 'Your Order'
        page.should have_content 'Sorry, your job offer needs improvement'

        click_link 'Review our suggestions'
        assert_active_nav_item 'Edit Project'
        page.should have_content offer.review_comment

        click_button 'Submit'
        assert_active_nav_item 'Your Order'
        page.should have_content 'We are reviewing your project'
      }.to change {offer.reload.status}.from(:rejected).to(:waiting_for_review)
    end

  end

  context 'when offer is accepted' do

    given!(:offer)  { FactoryGirl.create(:job_offer, status: :accepted, client: client, order: order) }

    scenario 'read project status' do
      visit offers_url
      assert_page_title 'My Offers'
      assert_offer_count 1

      page.should have_content 'Active'
      click_link offer.title

      assert_active_nav_item 'Your Order'
      page.should have_content 'Your project has been accepted.'

      click_link 'View Project'
      assert_active_nav_item 'View Project'
      page.should have_content offer.company_description
      page.should have_content offer.project_summary
      page.should have_content offer.project_details

      click_link 'Edit Project'
      assert_active_nav_item 'Edit Project'

      click_button 'Submit'
      assert_active_nav_item 'Edit Project'
      page.should have_content 'Your offer has been successfully updated!'
    end

  end

  def assert_page_title(title)
    find('.title h1').should have_content(title)
  end

  def assert_active_nav_item(title)
    find('#subnav li a.current').should have_content(title)
  end

  def assert_offer_count(count)
    page.should have_selector('ul.offer-list > li', count: count)
  end

end
