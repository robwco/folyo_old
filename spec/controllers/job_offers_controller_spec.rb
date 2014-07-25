require "spec_helper"

describe Client::JobOffersController do

  describe "archive" do

    let!(:client) { FactoryGirl.create :client }
    let!(:job_offer) { FactoryGirl.create :job_offer, :client => client, status: :accepted }
    let!(:designers) { 5.times.map { FactoryGirl.create :designer } }
    let!(:designer_replies) { 5.times.map {|i| FactoryGirl.create :designer_reply, :designer => designers[i], :job_offer => job_offer } }

    it "archives job offers" do
      sign_in(client)
      expect {
        post :archive, id: job_offer.id
      }.to change { job_offer.reload.designer_replies.where(picked: true).count }.by(0)
      job_offer.reload.should be_archived
    end

    it "marks designer replies as picked" do
      sign_in(client)
      expect {
        post :archive, id: job_offer.id, designer_users: designers.first.id
      }.to change { job_offer.reload.designer_replies.where(picked: true).count }.by(1)
    end

    it "sends emails to designers who have not been picked" do
      sign_in(client)
      expect {
        post :archive, id: job_offer.id, designer_users: designers.first.id
      }.to change { ActionMailer::Base.deliveries.size }.by(4)
    end

    it "is forbidden to anonymous users" do
      post :archive, id: job_offer.id
      job_offer.reload.should_not be_archived
      response.should redirect_to('/sign_in')
    end

  end

end
