require 'spec_helper'

describe Client::EvaluationsController do

  let(:n) { 5 }
  let!(:client) { FactoryGirl.create :client }
  let!(:job_offer) { FactoryGirl.create :job_offer, client: client, status: :archived }
  let!(:designers) { n.times.map { FactoryGirl.create :designer } }
  let!(:designer_replies) { n.times.map { |i| FactoryGirl.create :designer_reply, designer: designers[i], job_offer: job_offer, picked: (i == 2) } }

  let(:picked_reply) { job_offer.designer_replies.where(picked: true).first }

  before do
    sign_in(client)
  end

  describe 'edit' do

    it "assigns existing evaluation" do
      picked_reply.update_attribute(:evaluation, 'existing evaluation')

      get :edit, offer_id: job_offer.id

      response.should be_success
      assigns[:designer].should_not be_nil
      assigns[:reply].evaluation.should == "existing evaluation"
    end

    it "assigns existing folyo evaluation" do
      evaluation = FactoryGirl.create :folyo_evaluation, user: client

      get :edit, offer_id: job_offer.id
      response.should be_success
      assigns[:folyo_evaluation].should == evaluation
    end

  end

  describe "update" do

    it "sets evaluation" do
      expect {
        put_evaluation ''
      }.to change { picked_reply.reload.evaluation }.from(nil).to('evaluation')
    end

    it "creates folyo evaluation" do
      expect {
        put_evaluation 'new evaluation'
      }.to change { FolyoEvaluation.count }.by(1)
    end

    it "updates folyo evaluation" do
      evaluation = FactoryGirl.create :folyo_evaluation, user: client

      expect {
        put_evaluation 'new evaluation'
      }.to change { FolyoEvaluation.count }.by(0)
      evaluation.reload.evaluation.should == 'new evaluation'
    end

    it "set job_offer status to rated" do
      expect {
        put_evaluation 'new evaluation'
      }.to change{job_offer.reload.status}.from(:archived).to(:rated)
    end

  end

  def put_evaluation(evaluation)
    put :update, offer_id: job_offer.id, reply_id: picked_reply.id, designer_reply: { evaluation: 'evaluation'}, folyo_evaluation: {evaluation: 'new evaluation'}
  end

end
