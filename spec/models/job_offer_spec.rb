require 'spec_helper'

describe JobOffer do

  describe 'state machine' do

    describe 'publish' do

      let(:job_offer) { FactoryGirl.create(:job_offer, status: :initialized) }

      subject { ->{ job_offer.publish } }

      it { should change{job_offer.reload.status}.from(:initialized).to(:waiting_for_submission)}

      it { should change{job_offer.reload.published_at}.from(nil) }

      it 'should track user event' do
        expect_to_track 'Save Job Offer'
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
          expect_to_track 'Submit Job Offer'
          subject.call
        end

      end

      context 'when job offer is waiting_for_submission' do

        let(:job_offer) { FactoryGirl.create(:job_offer, status: :waiting_for_submission) }

        it { should change{job_offer.reload.status}.from(:waiting_for_submission).to(:waiting_for_payment)}

        it { should change{job_offer.reload.submited_at}.from(nil) }

        it 'should track user event' do
          expect_to_track 'Submit Job Offer'
          subject.call
        end

      end

      context 'when job offer is rejected' do

        let(:job_offer) { FactoryGirl.create(:job_offer, status: :rejected, review_comment: 'rejection comment') }

        it { should change{job_offer.reload.status}.from(:rejected).to(:waiting_for_review)}

        it { should change{job_offer.reload.submited_at}.from(nil) }

        it 'should track user event' do
          expect_to_track 'Submit Job Offer'
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
        expect_to_track 'Pay Job Offer'
        subject.call
      end

    end

    describe 'accept' do

      let(:job_offer) { FactoryGirl.create(:job_offer, status: :waiting_for_review) }

      subject { ->{ job_offer.accept } }

      it { should change{job_offer.reload.status}.from(:waiting_for_review).to(:accepted)}

      it { should change{job_offer.reload.approved_at}.from(nil) }

      it 'should track user event' do
        expect_to_track 'Job Offer Accepted'
        subject.call
      end

    end

    describe 'reject' do

      let(:job_offer) { FactoryGirl.create(:job_offer, status: :waiting_for_review) }

      subject { ->{ job_offer.reject('rejection comment') } }

      it { should change{job_offer.reload.status}.from(:waiting_for_review).to(:rejected)}

      it { should change{job_offer.reload.rejected_at}.from(nil) }

      it 'should track user event' do
        expect_to_track 'Job Offer Rejected'
        subject.call
      end

    end

    describe 'mark_as_sent' do

      let(:job_offer) { FactoryGirl.create(:job_offer, status: :accepted) }

      subject { ->{ job_offer.mark_as_sent } }

      it { should change{job_offer.reload.status}.from(:accepted).to(:sent)}

      it { should change{job_offer.reload.sent_at}.from(nil) }

      it 'should track user event' do
        expect_to_track 'Job Offer Sent'
        subject.call
      end

    end

    describe 'archive' do

      let(:job_offer) { FactoryGirl.create(:job_offer, status: :sent) }

      subject { ->{ job_offer.archive } }

      it { should change{job_offer.reload.status}.from(:sent).to(:archived)}

      it { should change{job_offer.reload.archived_at}.from(nil) }

      it 'should track user event' do
        expect_to_track 'Archive Job Offer'
        subject.call
      end

    end

    describe 'rate' do

      let(:job_offer) { FactoryGirl.create(:job_offer, status: :archived) }

      subject { ->{ job_offer.rate } }

      it { should change{job_offer.reload.status}.from(:archived).to(:rated)}

      it { should change{job_offer.reload.rated_at}.from(nil) }

      it 'should track user event' do
        expect_to_track 'Leave a Rating'
        subject.call
      end

    end

    describe 'refund' do

      subject { ->{ job_offer.refund } }

      context 'when job offer is sent' do

        let(:job_offer) { FactoryGirl.create(:job_offer, status: :sent, order: FactoryGirl.build(:order)) }

        it { should change{job_offer.reload.status}.from(:sent).to(:refunded)}

        it 'should track user event' do
          expect_to_track 'Job Offer Refunded'
          subject.call
        end
      end

      context 'when job offer is rejected' do

        let(:job_offer) { FactoryGirl.create(:job_offer, status: :rejected, order: FactoryGirl.build(:order), review_comment: 'rejection comment') }

        it { should change{job_offer.reload.status}.from(:rejected).to(:waiting_for_submission)}

        it 'should track user event' do
          expect_to_track 'Job Offer Refunded'
          subject.call
        end

      end

    end

  end

  def expect_to_track(event_name)
    job_offer.client.should_receive(:track_user_event) do |value|
      value.should == event_name
    end
  end

end