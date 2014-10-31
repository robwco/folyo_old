require 'spec_helper'

feature 'Fill in a budget survey', devise: true do

  given(:designer) { FactoryGirl.create(:designer) }

  given(:designing_since) { '3-4 years' }
  given(:billing_mode) { 'By the week' }
  given(:hourly_rate) { '100' }

  background do
    login_as designer
  end

  scenario 'go through all survey forms' do
    expect {
      visit survey_path 'budget'
    }.to change { Survey.count }.by(1)

    survey = Survey.last
    survey.user.should == designer

    # 01 - About You
    click_link 'Get Started'
    select designing_since, from: 'survey_designing_since'
    select billing_mode, from: 'survey_billing_mode'
    fill_in 'survey_hourly_rate', with: hourly_rate

    click_button 'bottom-next'
    survey.reload.designing_since.should == designing_since
    survey.billing_mode.should == billing_mode
    survey.hourly_rate.should == hourly_rate

    click_button 'top-prev'
    find('#survey_designing_since').value.should == designing_since
    find('#survey_billing_mode').value.should == billing_mode
    find('#survey_hourly_rate').value.should == hourly_rate

    fill_survey_section(%w(logo full_identity))
    fill_survey_section(%w(illustration icon_design))
    fill_survey_section(%w(animated_trailer))
    fill_survey_section(%w(coming_soon coming_soon_coding landing_page landing_page_coding simple_website simple_website_coding complex_website complex_website_coding))
    fill_survey_section(%w(simple_mobile_app complex_mobile_app simple_web_app simple_web_app_coding complex_web_app complex_web_app_coding))
    fill_survey_section(%w(typeface_design simple_lettering complex_lettering))
    fill_survey_section(%w(annual_report magazine book)) { click_link 'Back' }
  end

  def fill_survey_section(fields, back_button = 'bottom-prev')
    fields.map! { |field| "#{field}_budget" }
    click_button 'top-next'

    field_values = fields.inject({}) { |h, field| h[field] = (rand(99) * 100).to_s; h }
    fields.each do |field|
      find("#survey_#{field}").set(field_values[field])
    end

    click_button 'top-next'
    survey = Survey.last.reload
    fields.each do |field|
      survey.send(field).should == field_values[field]
    end

    block_given? ? yield : click_button('bottom-prev')
    fields.each do |field|
      find("#survey_#{field}").value.should == field_values[field]
    end
  end

end