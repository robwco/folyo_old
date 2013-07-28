require 'spec_helper'

describe JobOffer do

  describe 'set_client_attributes' do

    let(:client)    { FactoryGirl.create(:client, company_name: nil )}
    let(:job_offer) { FactoryGirl.create(:job_offer, status: :initialized, client: client) }
    let(:new_company_name) { 'new company name' }

    subject { ->{ job_offer.update_attribute(:company_name, new_company_name)} }

    it { should change{job_offer.reload.company_name}.to(new_company_name)}

    it { should change{client.reload.company_name}.from(nil).to(new_company_name)}

  end

  describe 'state machine' do

    describe 'publish' do

      let(:job_offer) { FactoryGirl.create(:job_offer, status: :initialized) }

      subject { ->{ job_offer.publish } }

      it { should change{job_offer.reload.status}.from(:initialized).to(:waiting_for_submission)}

      it { should change{job_offer.reload.published_at}.from(nil) }

      it 'should track user event' do
        expect_to_track 'JO02_Save'
        subject.call
      end

    end

    describe 'submit' do

      subject { ->{ job_offer.submit } }

      context 'when job offer is initialized' do

        let(:job_offer) { FactoryGirl.create(:job_offer, status: :initialized) }

        it { should change{job_offer.reload.status}.from(:initialized).to(:waiting_for_payment)}

        it { should change{job_offer.reload.published_at}.from(nil) }

        it { should change{job_offer.reload.submited_at}.from(nil) }

        it 'should track user event' do
          expect_to_track 'JO03_Submit'
          subject.call
        end

      end

      context 'when job offer is waiting_for_submission' do

        let(:job_offer) { FactoryGirl.create(:job_offer, status: :waiting_for_submission) }

        it { should change{job_offer.reload.status}.from(:waiting_for_submission).to(:waiting_for_payment)}

        it { should change{job_offer.reload.submited_at}.from(nil) }

        it 'should track user event' do
          expect_to_track 'JO03_Submit'
          subject.call
        end

      end

      context 'when job offer is rejected' do

        let(:job_offer) { FactoryGirl.create(:job_offer, status: :rejected, review_comment: 'rejection comment') }

        it { should change{job_offer.reload.status}.from(:rejected).to(:waiting_for_review)}

        it { should change{job_offer.reload.submited_at}.from(nil) }

        it 'should track user event' do
          expect_to_track 'JO05c_Resubmit'
          subject.call
        end

      end

    end

    describe 'pay' do

      let(:job_offer) { FactoryGirl.create(:job_offer, status: :waiting_for_payment) }

      subject { ->{ job_offer.pay } }

      it { should change{job_offer.reload.status}.from(:waiting_for_payment).to(:waiting_for_review)}

      it { should change{job_offer.reload.paid_at}.from(nil) }

      it 'should track user event' do
        expect_to_track 'JO04_Pay'
        subject.call
      end

    end

    describe 'accept' do

      let(:job_offer) { FactoryGirl.create(:job_offer, status: :waiting_for_review) }

      subject { ->{ job_offer.accept } }

      it { should change{job_offer.reload.status}.from(:waiting_for_review).to(:accepted)}

      it { should change{job_offer.reload.approved_at}.from(nil) }

      it 'should track user event' do
        expect_to_track 'JO05b_Accepted'
        subject.call
      end

    end

    describe 'reject' do

      let(:rejection_comment) { 'rejection comment' }
      let(:job_offer) { FactoryGirl.create(:job_offer, status: :waiting_for_review) }

      subject { ->{ job_offer.reject(rejection_comment) } }

      it { should change{job_offer.reload.status}.from(:waiting_for_review).to(:rejected)}

      it { should change{job_offer.reload.rejected_at}.from(nil) }

      it 'should track user event' do
        expect_to_track 'JO05a_Rejected', job_offer_rejected_reason: rejection_comment
        subject.call
      end

    end

    describe 'mark_as_sent' do

      let(:job_offer) { FactoryGirl.create(:job_offer, status: :accepted) }

      subject { ->{ job_offer.mark_as_sent } }

      it { should change{job_offer.reload.status}.from(:accepted).to(:sent)}

      it { should change{job_offer.reload.sent_at}.from(nil) }

      it 'should track user event' do
        expect_to_track 'JO06_Sent'
        subject.call
      end

    end

    describe 'archive' do

      let(:job_offer) { FactoryGirl.create(:job_offer, status: :sent) }

      subject { ->{ job_offer.archive } }

      it { should change{job_offer.reload.status}.from(:sent).to(:archived)}

      it { should change{job_offer.reload.archived_at}.from(nil) }

      it 'should track user event' do
        expect_to_track 'JO07a_Archive'
        subject.call
      end

    end

    describe 'rate' do

      let(:job_offer) { FactoryGirl.create(:job_offer, status: :archived) }

      subject { ->{ job_offer.rate } }

      it { should change{job_offer.reload.status}.from(:archived).to(:rated)}

      it { should change{job_offer.reload.rated_at}.from(nil) }

      it 'should track user event' do
        expect_to_track 'JO08_Rate'
        subject.call
      end

    end

    describe 'refund' do

      subject { ->{ job_offer.refund } }

      context 'when job offer is sent' do

        let(:job_offer) { FactoryGirl.create(:job_offer, status: :sent, order: FactoryGirl.build(:order)) }

        it { should change{job_offer.reload.status}.from(:sent).to(:refunded)}

        it 'should track user event' do
          expect_to_track 'JOXX_Refunded'
          subject.call
        end
      end

      context 'when job offer is rejected' do

        let(:job_offer) { FactoryGirl.create(:job_offer, status: :rejected, order: FactoryGirl.build(:order), review_comment: 'rejection comment') }

        it { should change{job_offer.reload.status}.from(:rejected).to(:waiting_for_submission)}

        it 'should track user event' do
          expect_to_track 'JOXX_Refunded'
          subject.call
        end

      end

    end

  end

  def expect_to_track(event_name, options = {})
    job_offer.client.should_receive(:track_user_event) do |value, vero_options|
      value.should == event_name
      options.each do |k, v|
        vero_options[k].should == v
      end
    end
  end

end