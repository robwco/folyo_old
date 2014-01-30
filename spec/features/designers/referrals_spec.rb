require 'spec_helper'

feature 'Manage referrals', devise: true do

  given(:designer) { FactoryGirl.create :designer }

  background do
    login_as(designer)
    visit root_path
  end

  feature 'referral balance' do

    background do
      FactoryGirl.create :accepted_job_offer, approved_at: 3.month.ago, referring_designer: designer, order: FactoryGirl.build(:order, referral_bonus_transfered_at: 3.days.ago)
      FactoryGirl.create :accepted_job_offer, approved_at: 3.month.ago, referring_designer: designer, order: FactoryGirl.build(:order, referral_bonus_transfered_at: nil)
      FactoryGirl.create :accepted_job_offer, approved_at: 3.weeks.ago, referring_designer: designer
      FactoryGirl.create :rejected_job_offer, referring_designer: designer
      click_refer_client
    end

    it "shows my exact balance" do
      find('.balance').should have_content("$19.8")
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