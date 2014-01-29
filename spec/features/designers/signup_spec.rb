require 'spec_helper'

describe 'Signup as a designer', type: :feature do

  let(:full_name)     { 'Bobby Joe' }
  let(:email)         { FactoryGirl.generate :email }
  let(:password)      { 'password' }
  let(:portfolio_url) { 'http://www.google.fr' }

  it 'creates a pending account' do
    expect {
      visit '/sign_up/designer'
      fill_in 'Full name',      with: full_name
      fill_in 'Email',          with: email
      fill_in 'Password',       with: password

      click_button 'Apply to join Folyo'
      page.should have_content 'error prohibited this designer from being saved'

      fill_in 'Password',       with: password
      fill_in 'Portfolio url',  with: portfolio_url
      click_button 'Apply to join Folyo'
      page.should have_content 'Welcome! You have signed up successfully.'
    }.to change {Designer.count}.by(1)

    designer = Designer.last
    designer.full_name.should == full_name
    designer.email.should == email
    designer.portfolio_url.should == portfolio_url
  end

end