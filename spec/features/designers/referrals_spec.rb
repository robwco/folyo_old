require 'spec_helper'

feature 'Manage referrals', devise: true do

  given(:designer) { FactoryGirl.create :designer }

  background do
    login_as(designer)
    visit root_path
  end

  context 'with recently accepted offer' do

    given!(:offer) { FactoryGirl.create :accepted_job_offer, referring_designer: designer }

    it 'shows a pending offer' do
      click_refer_client
      assert_referrals_count(1, :pending)
    end

  end

  context 'with 3 months old accepted offer' do

    given!(:offer) { FactoryGirl.create :accepted_job_offer, approved_at: 3.month.ago, referring_designer: designer }

    it 'shows an accepted offer' do
      click_refer_client
      assert_referrals_count(1, :ok, '$19.8')
    end

  end

  context 'with rejected offer' do
    given!(:offer) { FactoryGirl.create :rejected_job_offer, referring_designer: designer }

    it 'shows a rejected offer' do
      click_refer_client
      assert_referrals_count(1, :ko)
    end
  end

  def click_refer_client
    click_link 'Refer a client'
  end

  def assert_referrals_count(count, selector_class = nil, content = nil)
    selector = ".history tr"
    selector += ".#{selector_class}" if selector_class
    page.should have_selector(selector, count: count)
    find(selector).should have_content(content) if content
  end

end