require 'spec_helper'

feature 'Paying a job offer', devise: true do

  given(:client)        { FactoryGirl.create(:client) }
  given(:offer)         { FactoryGirl.create(:job_offer, status: :waiting_for_payment, client: client) }
  given(:express_token) { 'a-token' }
  given(:confirm_url)   { confirm_offer_order_url(offer, token: express_token) }

  context 'when logged in as offer creator' do

    background do
      login_as client
      EXPRESS_GATEWAY.should_receive(:setup_purchase).and_return(OpenStruct.new(token: express_token))
      EXPRESS_GATEWAY.should_receive(:redirect_url_for).and_return(confirm_url)
      EXPRESS_GATEWAY.should_receive(:details_for).any_number_of_times.with(express_token).and_return(OpenStruct.new(payer_id: rand, params: {'PayerInfo' => {'Payer' => rand}, 'OrderTotal' => rand}))
      EXPRESS_GATEWAY.should_receive(:purchase).and_return(OpenStruct.new(success?: true, params: {transaction_id: rand}))
    end

    scenario 'successful payment' do
      expect {
        visit new_offer_order_url(offer)

        page.should have_content 'Complete Your Payment'
        page.should have_content offer.display_price

        click_link 'paypal-checkout'
        current_url.should == confirm_url

        click_button 'Confirm Payment'
      }.to change {offer.reload.status}.from(:waiting_for_payment).to(:waiting_for_review)
    end

  end

  context 'when not logged in as offer creator' do

    scenario 'successful payment' do
      visit new_offer_order_url(offer)
      page.should have_content 'You are not authorized to access this page'
    end

  end

end