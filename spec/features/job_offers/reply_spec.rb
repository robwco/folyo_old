require 'spec_helper'

feature 'Replying to an offer', devise: true do

  given(:designer) { FactoryGirl.create :designer, status: :accepted }
  given(:offer)    { FactoryGirl.create :job_offer }
  given(:message) { 'A sample but long enough answer' }

  context 'when having not replied to the offer yet' do

    background do
      login_as(designer)
      visit offer_path(offer)
    end

    scenario 'reply to offer' do
      expect {
        fill_in 'Add a short message for the client', with: message
        click_button 'Send your profile'
      }.to change { offer.reload.designer_replies.length }.by(1)

      offer.designer_replies.last.message.should == message
      offer.designer_replies.last.designer.should == designer
    end

    scenario 'try to send profile without a reply' do
      expect {
        fill_in 'Add a short message for the client', with: ''
        click_button 'Send your profile'
      }.to change { offer.reload.designer_replies.length }.by(0)
    end

    scenario 'try to send profile with a too long reply' do
      expect {
        fill_in 'Add a short message for the client', with: ("a" * 500)
        click_button 'Send your profile'
      }.to change { offer.reload.designer_replies.length }.by(0)
    end

  end

  context 'when having already replied to the offer' do

    given!(:reply) { FactoryGirl.create :designer_reply, job_offer: offer, designer: designer }

    background do
      login_as(designer)
      visit offer_path(offer)
    end

    scenario 'updating the reply' do
      page.should have_content reply.message
       expect {
        fill_in 'Add a short message for the client', with: message
        click_button 'Send your profile'
      }.to change { reply.reload.message }.to(message)
    end

  end

end
