require 'spec_helper'

describe JobOffer do

  describe 'state machine' do

    describe 'publish' do

      let(:job_offer) { FactoryGirl.create(:job_offer, status: :initialized) }

      subject { ->{ job_offer.publish } }

      it { should change{job_offer.reload.status}.from(:initialized).to(:waiting_for_payment)}

      it { should change{job_offer.reload.published_at}.from(nil) }

      it 'should track user event' do
        expect_to_track 'published'
        subject.call
      end

    end

    describe 'pay' do

      let(:job_offer) { FactoryGirl.create(:job_offer, status: :waiting_for_payment) }

      subject { ->{ job_offer.pay } }

      it { should change{job_offer.reload.status}.from(:waiting_for_payment).to(:waiting_for_review)}

      it { should change{job_offer.reload.paid_at}.from(nil) }

      it 'should track user event' do
        expect_to_track 'paid'
        subject.call
      end

    end

    describe 'accept' do

      let(:job_offer) { FactoryGirl.create(:job_offer, status: :waiting_for_review) }

      subject { ->{ job_offer.accept } }

      it { should change{job_offer.reload.status}.from(:waiting_for_review).to(:accepted)}

      it { should change{job_offer.reload.approved_at}.from(nil) }

      it 'should track user event' do
        expect_to_track 'accepted'
        subject.call
      end

    end

    describe 'reject' do

      let(:job_offer) { FactoryGirl.create(:job_offer, status: :waiting_for_review) }

      subject { ->{ job_offer.reject } }

      it { should change{job_offer.reload.status}.from(:waiting_for_review).to(:rejected)}

      it 'should track user event' do
        expect_to_track 'rejected'
        subject.call
      end

    end

    describe 'refund' do

      subject { ->{ job_offer.refund } }

      context 'when job offer is accepted' do

        let(:job_offer) { FactoryGirl.create(:job_offer, status: :accepted) }

        it { should change{job_offer.reload.status}.from(:accepted).to(:refunded)}

        it 'should track user event' do
          expect_to_track 'refunded'
          subject.call
        end
      end

      context 'when job offer is rejected' do

        let(:job_offer) { FactoryGirl.create(:job_offer, status: :rejected) }

        it { should change{job_offer.reload.status}.from(:rejected).to(:initialized)}

        it 'should track user event' do
          expect_to_track 'refunded'
          subject.call
        end

      end

    end

  end

  def expect_to_track(event_name)
    job_offer.client.should_receive(:track_user_event) do |value|
      value.should match /.*#{event_name}.*/i
    end
  end

end