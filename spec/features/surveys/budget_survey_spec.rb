require 'spec_helper'

feature 'Fill in a budget survey', devise: true do

  given(:designer) { FactoryGirl.create(:designer) }

  given(:designing_since) { '3-4 years' }
  given(:billing_mode) { 'By the week' }
  given(:hourly_rate) { '100' }

  given(:logo_budget) { '3000' }
  given(:full_identity_budget) { '5000' }

  given(:illustration_budget) { '2100' }
  given(:icon_design_budget) { '6000' }

  given(:coming_soon_budget) { '2000' }
  given(:coming_soon_coding_budget) { '3000' }
  given(:landing_page_budget) { '1000' }
  given(:landing_page_coding_budget) { '1500' }
  given(:simple_website_budget) { '2000' }
  given(:simple_website_coding_budget) { '2700' }
  given(:complex_website_budget) { '4000' }
  given(:complex_website_coding_budget) { '6000' }

  given(:simple_mobile_app_budget) { '2200' }
  given(:complex_mobile_app_budget) { '3500' }
  given(:simple_web_app_budget) { '2600' }
  given(:simple_web_app_coding_budget) { '3000' }
  given(:complex_web_app_budget) { '4000' }
  given(:complex_web_app_coding_budget) { '6100' }

  given(:animated_trailer_budget) { '7500' }

  given(:ux_consulting_budget) { '3600' }
  given(:ux_research_budget) { '6700' }
  given(:information_architecture_budget) { '9000' }

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

    # 02 - Logo Design
    click_button 'top-next'
    find('#survey_logo_budget').set(logo_budget)
    find('#survey_full_identity_budget').set(full_identity_budget)

    click_button 'bottom-next'
    survey.reload.logo_budget.should == logo_budget
    survey.reload.full_identity_budget.should == full_identity_budget

    click_button 'bottom-prev'
    find('#survey_logo_budget').value.should == logo_budget
    find('#survey_full_identity_budget').value.should == full_identity_budget

    # 03 - Illustration
    click_button 'top-next'
    find('#survey_illustration_budget').set(illustration_budget)
    find('#survey_icon_design_budget').set(icon_design_budget)

    click_button 'top-next'
    survey.reload.illustration_budget.should == illustration_budget
    survey.reload.icon_design_budget.should == icon_design_budget

    click_button 'bottom-prev'
    find('#survey_illustration_budget').value.should == illustration_budget
    find('#survey_icon_design_budget').value.should == icon_design_budget

    # 06 - Motion Design
    click_button 'top-next'
    find('#survey_animated_trailer_budget').set(animated_trailer_budget)

    click_button 'top-next'
    survey.reload.animated_trailer_budget.should == animated_trailer_budget

    click_button 'bottom-prev'
    find('#survey_animated_trailer_budget').value.should == animated_trailer_budget

    # 04 - Web Design
    click_button 'bottom-next'
    find('#survey_coming_soon_budget').set(coming_soon_budget)
    find('#survey_coming_soon_coding_budget').set(coming_soon_coding_budget)
    find('#survey_landing_page_budget').set(landing_page_budget)
    find('#survey_landing_page_coding_budget').set(landing_page_coding_budget)
    find('#survey_simple_website_budget').set(simple_website_budget)
    find('#survey_simple_website_coding_budget').set(simple_website_coding_budget)
    find('#survey_complex_website_budget').set(complex_website_budget)
    find('#survey_complex_website_coding_budget').set(complex_website_coding_budget)

    click_button 'bottom-next'
    survey.reload.coming_soon_budget.should == coming_soon_budget
    survey.reload.coming_soon_coding_budget.should == coming_soon_coding_budget
    survey.reload.landing_page_budget.should == landing_page_budget
    survey.reload.landing_page_coding_budget.should == landing_page_coding_budget
    survey.reload.simple_website_budget.should == simple_website_budget
    survey.reload.simple_website_coding_budget.should == simple_website_coding_budget
    survey.reload.complex_website_budget.should == complex_website_budget
    survey.reload.complex_website_coding_budget.should == complex_website_coding_budget

    click_button 'bottom-prev'
    find('#survey_coming_soon_budget').value.should == coming_soon_budget
    find('#survey_coming_soon_coding_budget').value.should == coming_soon_coding_budget
    find('#survey_landing_page_budget').value.should == landing_page_budget
    find('#survey_landing_page_coding_budget').value.should == landing_page_coding_budget
    find('#survey_simple_website_budget').value.should == simple_website_budget
    find('#survey_simple_website_coding_budget').value.should == simple_website_coding_budget
    find('#survey_complex_website_budget').value.should == complex_website_budget
    find('#survey_complex_website_coding_budget').value.should == complex_website_coding_budget

    # 05 - UI design
    click_button 'bottom-next'
    find('#survey_simple_mobile_app_budget').set(simple_mobile_app_budget)
    find('#survey_complex_mobile_app_budget').set(complex_mobile_app_budget)
    find('#survey_simple_web_app_budget').set(simple_web_app_budget)
    find('#survey_simple_web_app_coding_budget').set(simple_web_app_coding_budget)
    find('#survey_complex_web_app_budget').set(complex_web_app_budget)
    find('#survey_complex_web_app_coding_budget').set(complex_web_app_coding_budget)

    click_button 'top-next'
    survey.reload.simple_mobile_app_budget.should == simple_mobile_app_budget
    survey.reload.complex_mobile_app_budget.should == complex_mobile_app_budget
    survey.reload.simple_web_app_budget.should == simple_web_app_budget
    survey.reload.simple_web_app_coding_budget.should == simple_web_app_coding_budget
    survey.reload.complex_web_app_budget.should == complex_web_app_budget
    survey.reload.complex_web_app_coding_budget.should == complex_web_app_coding_budget

    click_link 'Back'
    find('#survey_simple_mobile_app_budget').value.should == simple_mobile_app_budget
    find('#survey_complex_mobile_app_budget').value.should == complex_mobile_app_budget
    find('#survey_simple_web_app_budget').value.should == simple_web_app_budget
    find('#survey_simple_web_app_coding_budget').value.should == simple_web_app_coding_budget
    find('#survey_complex_web_app_budget').value.should == complex_web_app_budget
    find('#survey_complex_web_app_coding_budget').value.should == complex_web_app_coding_budget

    # Check attributes are copied to designer
    designer.reload.skills_budgets['logo_and_identity_design']['logo'].should == logo_budget.to_f
    designer.skills_budgets['UI_design']['simple_mobile_app'].should == simple_mobile_app_budget.to_f
  end

end