require 'spec_helper'

describe 'Posting a job offer', type: :feature do

  let(:full_name)       { 'Bobby Joe' }
  let(:email)           { FactoryGirl.generate :email }
  let(:password)        { 'password' }
  let(:company_name)    { 'Big corporation' }
  let(:company_desc)    { 'Big corporation description' }
  let(:title)           { 'A job offer' }
  let(:project_summary) { 'Project summary' }
  let(:project_details) { 'Project details' }

  it "creates a new job offer" do
    expect {
      expect {
        visit root_path

        click_link 'Post a Job'
        page.should have_content '3 Good Reasons to Use Folyo'

        within '#intro-header' do
          click_link 'Get Started'
        end
        page.should have_content 'Submit a Job Offer'

        click_button 'Submit Job Offer'
        page.should have_content 'errors prohibited this job offer from being saved'

        within '#new_job_offer' do
          fill_in 'Full name',           with: full_name
          fill_in 'Email',               with: email
          fill_in 'Password',            with: password
          fill_in 'Company name',        with: company_name
          fill_in 'Company description', with: company_desc
          fill_in 'Title',               with: title
          fill_in 'Project summary',     with: project_summary
          fill_in 'Project details',     with: project_details
          check   'Icon design'
          select  '$1500-$2000', from: 'Budget Range'
        end

        click_button 'Submit Job Offer'
        page.should have_content 'Complete Your Payment'
      }.to change { User.count + JobOffer.count }.by(2)
    }.to change { ActionMailer::Base.deliveries.size }.by(1)

    c = Client.last
    c.full_name.should == full_name
    c.email.should == email
    c.company_name.should == company_name
    c.company_description.should == company_desc

    offer = JobOffer.last
    offer.client.should == c
    offer.title.should == title
    offer.project_summary.should == project_summary
    offer.project_details.should == project_details
    offer.should have(1).skill
  end

end