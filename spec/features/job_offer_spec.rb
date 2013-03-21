require 'spec_helper'

describe 'Posting a job offer', :type => :feature do

  let(:full_name)     { 'Bobby Joe' }
  let(:email)         { 'bobby.joe@gmail.com' }
  let(:password)      { 'password' }
  let(:company_name)  { 'Big corporation' }
  let(:company_desc)  { 'Big corporation description' }
  let(:title)         { 'A job offer' }
  let(:full_desc)     { 'Full job description' }

  it "creates a new job offer" do
    expect {
      visit root_path

      click_link 'Post a Job'
      page.should have_content '3 Good Reasons to Use Folyo'

      click_link 'Get Started'
      page.should have_content 'Submit a Job Offer'

      click_button 'Next: Your Project'
      page.should have_content 'errors prohibited this user from being saved'

      within '#new-client-form' do
        fill_in 'Full name', with: full_name
        fill_in 'Email',     with: email
        fill_in 'Password',  with: password
      end
      click_button 'Next: Your Project'
      page.should have_content 'errors prohibited this user from being saved'

      within '#new-client-form' do
        fill_in 'Password',            with: password
        fill_in 'Company name',        with: company_name
        fill_in 'Company description', with: company_desc
      end
      click_button 'Next: Your Project'
      page.should have_content 'Welcome! You have signed up successfully.'
    }.to change { User.count }.by(1)

    u = User.last
    u.full_name.should == full_name
    u.email.should == email
    u.role.should == 'client'
    u.client.company_name.should == company_name
    u.client.company_description.should == company_desc

    expect {
      click_button 'Submit Job Offer'
      page.should have_content 'errors prohibited this job offer from being saved'

      within '#new_job_offer' do
        fill_in 'Title', with: title
        fill_in 'Full description' , with: full_desc
        check 'Icon design'
      end
      click_button 'Submit Job Offer'
      page.should have_content 'Job offer was successfully created.'
    }.to change { JobOffer.count }.by(1)

    offer = JobOffer.last
    offer.title.should == title
    offer.full_description.should == full_desc
    offer.should have(1).skill
  end

end