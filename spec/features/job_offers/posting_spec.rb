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

    let(:wizard_size) { 3 }

    background do
      visit root_path
      click_link 'Find a Designer'
    end

    scenario 'create an account and submit a new offer' do

      expect {
        assert_page_title 'Your Job Offer'
        assert_active_wizard_item 'Sign Up'

        # creating account without filling in the form will trigger validation errors
        click_button 'Sign Up'
        page.should have_content 'errors prohibited this client from being saved'

        # really signing up
        fill_client_form
        click_button 'Sign Up'

        # now on wizard 2nd step
        assert_page_title 'Your Job Offer'
        assert_active_wizard_item 'Your Project'

        # navigating in wizard
        click_link 'Sign Up'
        assert_active_wizard_item 'Sign Up'
        click_link 'Your Project'

        # submitting the offer without filling in the form will trigger validation errors
        click_button 'Submit'
        page.should have_content 'errors prohibited this job offer from being saved'

        # really submitting the offer
        fill_job_offer_form
        click_button 'Submit'

        # now on payment page
        assert_page_title title
        assert_active_wizard_item 'Payment'

        # navigating in wizard
        click_link 'Your Project'
        assert_active_wizard_item 'Your Project'
        click_link 'Payment'
        assert_active_wizard_item 'Payment'
      }.to change { Client.count + JobOffer.count }.by(2)

      client = Client.last
      client.full_name.should == full_name
      client.email.should == email
      client.company_name.should == company_name
      client.company_description.should == company_desc

      assert_job_offer_creation(client)
      last_offer.should be_waiting_for_payment
    end

  end

  context 'when logged in as a client' do

    let(:wizard_size) { 2 }

    background do
      login_as(client)
      visit root_path
      click_link 'My Offers'
    end

    scenario 'post a new offer' do
      expect {
        click_link 'Submit new job offer'

        assert_page_title 'Your Job Offer'
        assert_active_wizard_item 'Your Project'

        # submitting the offer without filling in the form will trigger validation error
        click_button 'Submit'
        page.should have_content 'errors prohibited this job offer from being saved'

        # really submitting the offer
        fill_job_offer_form
        click_button 'Submit'

        # now on payment page
        assert_page_title title
        assert_active_wizard_item 'Payment'

        # navigating in wizard
        click_link 'Your Project'
        assert_active_wizard_item 'Your Project'
        click_link 'Payment'
        assert_active_wizard_item 'Payment'
      }.to change { User.count + JobOffer.count }.by(1)

      assert_job_offer_creation(client)
      last_offer.should be_waiting_for_payment
    end

    scenario 'refreshing page does not create new offers' do
      expect {
        click_link 'Submit new job offer'
        visit(current_url)
      }.to change { JobOffer.count }.by(1)
    end

  end

  def fill_client_form
    within '#new-client-form' do
      fill_in 'Full name', with: full_name
      fill_in 'Email',     with: email
      fill_in 'Password',  with: password
    end
  end

  def fill_job_offer_form
    within 'form.edit_job_offer' do
      fill_in 'Company name',        with: company_name
      fill_in 'Company description', with: company_desc
      fill_in 'Title',               with: title
      fill_in 'Project summary',     with: project_summary
      fill_in 'Project details',     with: project_details
      check   'Icon design'
      select  '$1500-$2000', from: 'Budget Range'
    end
  end

  def assert_job_offer_creation(client)
    last_offer.client.should == client
    last_offer.title.should == title
    last_offer.project_summary.should == project_summary
    last_offer.project_details.should == project_details
    last_offer.should have(1).skill
  end

  def assert_page_title(title)
    find('h1.title').should have_content(title)
  end

  def assert_active_wizard_item(title)
    find('.wizard li.active').should have_content(title)
    if wizard_size
      find('.wizard').should have_selector('li', count: wizard_size)
    end
  end

end