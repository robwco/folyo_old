require 'spec_helper'

feature 'Posting a job offer', devise: true do

  given(:client)          { FactoryGirl.create :client }
  given(:email)           { FactoryGirl.generate :email }
  given(:full_name)       { 'Bobby Joe' }
  given(:password)        { 'password' }
  given(:company_name)    { 'Big corporation' }
  given(:company_desc)    { 'Big corporation description' }
  given(:title)           { 'A job offer' }
  given(:project_summary) { 'Project summary' }
  given(:project_details) { 'Project details' }
  given(:last_offer)      { JobOffer.last }

  context 'when not logged in' do

    background do
      visit root_path
      click_link 'Post a Job'
      page.should have_content '3 Good Reasons to Use Folyo'

      within '#intro-header' do
        click_link 'Get Started'
      end
    end

    scenario 'submit a new offer' do

      expect {
        assert_page_title 'Your Job Offer'
        assert_active_wizard_item 'Your Project'

        page.should have_content 'Your Account'

        submit_job_offer_form(:submit)
        page.should have_content 'errors prohibited this job offer from being saved'

        fill_client_form
        fill_in 'Title', with: title
        submit_job_offer_form(:submit)
        page.should have_content 'errors prohibited this job offer from being saved'

        fill_client_form
        fill_job_offer_form
        submit_job_offer_form(:submit)

        assert_active_wizard_item 'Payment'
      }.to change { User.count + JobOffer.count }.by(2)

      client = Client.last
      client.full_name.should == full_name
      client.email.should == email
      client.company_name.should == company_name
      client.company_description.should == company_desc

      assert_job_offer_creation(client, with_optional_fields: true)
      last_offer.should be_waiting_for_payment
    end

    scenario 'save a new offer' do

      expect {
        assert_page_title 'Your Job Offer'
        assert_active_wizard_item 'Your Project'

        page.should have_content 'Your Account'
        submit_job_offer_form(:save)
        page.should have_content 'errors prohibited this job offer from being saved'

        fill_client_form
        fill_in 'Title', with: title
        submit_job_offer_form(:save)
        assert_active_wizard_item 'Your Project'
        page.should_not have_content 'errors prohibited this job offer from being saved'
      }.to change { User.count + JobOffer.count }.by(2)

      client = Client.last
      client.full_name.should == full_name
      client.email.should == email

      assert_job_offer_creation(client, with_optional_fields: false)
      last_offer.should be_waiting_for_submission
    end

    scenario 'use an existing email adress' do
      fill_in 'Full name', with: client.full_name
      fill_in 'Email',     with: client.email
      fill_in 'Password',  with: client.password

      submit_job_offer_form(:save)
      page.should have_content 'It seems you already have an account'
    end

  end

  context 'when logged in as a client' do

    background do
      login_as(client)
      visit root_path
      click_link 'My Offers'
      click_link 'Submit new job offer'
    end

    scenario 'post a new offer' do
      expect {
        assert_page_title 'Your Job Offer'
        assert_active_wizard_item 'Your Project'

        page.should_not have_content 'Your Account'

        fill_in 'Title', with: title
        submit_job_offer_form(:submit)
        page.should have_content 'errors prohibited this job offer from being saved'

        fill_job_offer_form
        submit_job_offer_form(:submit)

        assert_active_wizard_item 'Payment'
      }.to change { User.count + JobOffer.count }.by(1)

      assert_job_offer_creation(client, with_optional_fields: true)
      last_offer.should be_waiting_for_payment
    end

    scenario 'save a new offer' do
      expect {
        assert_page_title 'Your Job Offer'
        assert_active_wizard_item 'Your Project'

        page.should_not have_content 'Your Account'

        fill_in 'Title', with: title
        submit_job_offer_form(:save)

        assert_active_wizard_item 'Your Project'
        page.should_not have_content 'errors prohibited this job offer from being saved'
      }.to change { User.count + JobOffer.count }.by(1)

      assert_job_offer_creation(client, with_optional_fields: false)
      last_offer.should be_waiting_for_submission
    end

  end

  def fill_client_form
    within '#new_job_offer' do
      fill_in 'Full name', with: full_name
      fill_in 'Email',     with: email
      fill_in 'Password',  with: password
    end
  end

  def fill_job_offer_form
    within '#new_job_offer' do
      fill_in 'Company name',        with: company_name
      fill_in 'Company description', with: company_desc
      fill_in 'Title',               with: title
      fill_in 'Project summary',     with: project_summary
      fill_in 'Project details',     with: project_details
      check   'Icon design'
      select  '$1500-$2000', from: 'Budget Range'
    end
  end

  def submit_job_offer_form(action)
    case action
    when :submit
      click_button 'Submit for review'
    when :save
      click_button 'Save'
    end
  end

  def assert_job_offer_creation(client, options = {})
    last_offer.client.should == client
    last_offer.title.should == title
    if options[:with_optional_fields]
      last_offer.project_summary.should == project_summary
      last_offer.project_details.should == project_details
      last_offer.should have(1).skill
    end
  end

  def assert_page_title(title)
    find('.title h1').should have_content(title)
  end

  def assert_active_wizard_item(title)
    find('.wizard li.active').should have_content(title)
  end

end