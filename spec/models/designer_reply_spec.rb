require "spec_helper"

describe DesignerReply do

  let(:offer) { FactoryGirl.create :job_offer }
  let(:shortlisted_reply) { FactoryGirl.build :designer_reply, status: :shortlisted }
  let(:hidden_reply)      { FactoryGirl.build :designer_reply, status: :hidden }
  let(:default_reply)     { FactoryGirl.build :designer_reply, status: :default }

  describe "length validation" do

    it "does not accept nil messages" do
      reply = FactoryGirl.build :designer_reply, message: nil, job_offer: offer
      reply.should_not be_valid
    end

    it "does not accept empty messages" do
      reply = FactoryGirl.build :designer_reply, message: '', job_offer: offer
      reply.should_not be_valid
    end

    it "does not accept too long messages messages" do
      reply = FactoryGirl.build :designer_reply, message: 'a' * 500, job_offer: offer
      reply.should_not be_valid
    end

    it "does not break offer validation" do
      reply = FactoryGirl.build :designer_reply, message: nil, job_offer: offer
      offer.should be_valid
      offer.save.should be_true
    end

    it "is possible to pick an invalid reply" do
      reply = FactoryGirl.build :designer_reply, message: nil, job_offer: offer, picked: false
      reply.save(validate: false)
      expect {
        offer.archive(reply.designer_id, false)
      }.to change { reply.reload.picked }.from(false).to(true)
    end

  end

  describe "shortlist toggle" do

    it "toggles attribute" do
      expect {
        shortlisted_reply.toggle_shortlisted!
      }.to change{shortlisted_reply.status}.from(:shortlisted).to(:default)

      expect {
        shortlisted_reply.toggle_shortlisted!
      }.to change{shortlisted_reply.reload.status}.from(:default).to(:shortlisted)
    end

    it "set given value" do
      expect {
        default_reply.toggle_shortlisted!(true)
        default_reply.toggle_shortlisted!(true)
      }.to change{default_reply.status}.from(:default).to(:shortlisted)

      expect {
        shortlisted_reply.toggle_shortlisted!(false)
        shortlisted_reply.toggle_shortlisted!(false)
      }.to change{shortlisted_reply.status}.from(:shortlisted).to(:default)
    end

  end

  describe "hide toggle" do

    it "toggles attribute" do
      expect {
        hidden_reply.toggle_hidden!
      }.to change{hidden_reply.status}.from(:hidden).to(:default)

      expect {
        hidden_reply.toggle_hidden!
      }.to change{hidden_reply.reload.status}.from(:default).to(:hidden)
    end

    it "set given value" do
      expect {
        default_reply.toggle_hidden!(true)
        default_reply.toggle_hidden!(true)
      }.to change{default_reply.status}.from(:default).to(:hidden)

      expect {
        hidden_reply.toggle_hidden!(false)
        hidden_reply.toggle_hidden!(false)
      }.to change{hidden_reply.status}.from(:hidden).to(:default)
    end

  end

end