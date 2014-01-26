require "spec_helper"

describe Admin::NewslettersController do

  describe "webhook" do

    let(:offer1) { FactoryGirl.create :job_offer, status: :accepted }
    let(:offer2) { FactoryGirl.create :job_offer, status: :sending }
    let(:newsletter) { FactoryGirl.create :newsletter, sent_at: nil, job_offers: [ offer1, offer2 ] }

    subject { newsletter.reload }
    before { post :webhook, webhook_post_data(newsletter) }

    its(:sent_at) { should_not be_nil }

    it "should mark newsletter offers as sent" do
      offer1.reload.should be_sent
      offer2.reload.should be_sent
    end

    its(:sent_at) { should_not be_nil }

    def webhook_post_data(newsletter)
      {
        type: "campaign",
        fired_at: "2009-03-26 21:31:21",
        data: {
          id: newsletter.mailchimp_cid,
          subject: "Test Campaign Subject",
          status: "sent",
          reason: "",
          list_id: "a6b5da1054"
        }
      }
    end

  end

end
