require 'spec_helper'

feature 'Posting a job offer', devise: true do

  given(:client)          { FactoryGirl.create :client }
  given(:full_name)       { 'Bobby Joe' }
  given(:email)           { FactoryGirl.generate :email }
  given(:password)        { 'password' }
  given(:company_name)    { 'Big corporation' }
  given(:company_desc)    { 'Big corporation description' }
  given(:title)           { 'A job offer' }
  given(:project_summary) { 'Project summary' }
  given(:project_details) { 'Project details' }

  scenario 'without an existing account', devise: true do

    expect {
      visit root_path

      click_link 'Post a Job'
      page.should have_content '3 Good Reasons to Use Folyo'

      within '#intro-header' do
        click_link 'Get Started'
      end
      page.should have_content 'Submit a Job Offer'

      page.should have_content 'Your Account'
      submit_job_offer_form
      page.should have_content 'errors prohibited this job offer from being saved'

      fill_job_offer_form

      page.should have_content 'Complete Your Payment'
    }.to change { User.count + JobOffer.count }.by(2)

    ActionMailer::Base.deliveries.size.should == 1

    client = Client.last
    client.full_name.should == full_name
    client.email.should == email
    client.company_name.should == company_name
    client.company_description.should == company_desc

    assert_job_offer_creation(client)
  end

  scenario 'with an existing client account' do
    login_as(client)

    expect {
      visit root_path
      click_link 'My Offers'
      click_link 'Submit new job offer'

      page.should have_content 'Submit a Job Offer'
      page.should_not have_content 'Your Account'
      fill_job_offer_form(false)
    }.to change { User.count + JobOffer.count }.by(1)

    assert_job_offer_creation(client)

    ActionMailer::Base.deliveries.size.should == 1
  end

  def fill_job_offer_form(with_user_data = true)
    within '#new_job_offer' do
      fill_in 'Full name',           with: full_name if with_user_data
      fill_in 'Email',               with: email     if with_user_data
      fill_in 'Password',            with: password  if with_user_data
      fill_in 'Company name',        with: company_name
      fill_in 'Company description', with: company_desc
      fill_in 'Title',               with: title
      fill_in 'Project summary',     with: project_summary
      fill_in 'Project details',     with: project_details
      check   'Icon design'
      select  '$1500-$2000', from: 'Budget Range'
    end
    submit_job_offer_form
  end

  def submit_job_offer_form
    click_button 'Submit Job Offer'
  end

  def assert_job_offer_creation(client)
    offer = JobOffer.last
    offer.client.should == client
    offer.title.should == title
    offer.project_summary.should == project_summary
    offer.project_details.should == project_details
    offer.should have(1).skill
    offer.should be_waiting_for_payment
  end

end