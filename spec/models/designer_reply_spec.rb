require "spec_helper"

describe DesignerReply do

  let(:offer) { FactoryGirl.create :job_offer }

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

end