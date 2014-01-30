require 'spec_helper'

describe Designer  do

  let(:designer)  { FactoryGirl.create :designer }

  subject { designer }

  describe 'referral balance' do

    before do
      FactoryGirl.create :accepted_job_offer, approved_at: 3.month.ago, referring_designer: designer, order: FactoryGirl.build(:order, referral_bonus_transfered_at: 3.days.ago)
      FactoryGirl.create :accepted_job_offer, approved_at: 3.month.ago, referring_designer: designer, order: FactoryGirl.build(:order, referral_bonus_transfered_at: nil)
      FactoryGirl.create :accepted_job_offer, approved_at: 3.weeks.ago, referring_designer: designer
      FactoryGirl.create :rejected_job_offer, referring_designer: designer
    end

    its(:referral_balance) { should == 19.8 }

  end

  describe 'referrals' do

    context 'with recently accepted offer' do

      let!(:offer) { FactoryGirl.create :accepted_job_offer, referring_designer: designer }

      its(:referrals) { should have(1).item }

      its("referrals.first") { should include(status: :pending) }

    end

    context 'with 3 months old accepted offer' do

      let!(:offer) { FactoryGirl.create :accepted_job_offer, approved_at: 3.month.ago, referring_designer: designer }

      its(:referrals) { should have(1).item }

      its("referrals.first") { should include(status: :available) }

      it "should have a label with matching amount" do
        subject.referrals.first[:label].should =~ /.*19\.8.*/
      end

    end

    context 'with bonus already transfered' do

      let!(:offer) { FactoryGirl.create :accepted_job_offer, approved_at: 3.month.ago, referring_designer: designer, order: FactoryGirl.build(:order, referral_bonus_transfered_at: 3.days.ago) }

      its(:referrals) { should have(1).item }

      its("referrals.first") { should include(status: :transfered) }

      it "should have a label with matching amount" do
        subject.referrals.first[:label].should =~ /.*19\.8.*/
      end

    end

    context 'with rejected offer' do

      let!(:offer) { FactoryGirl.create :rejected_job_offer, referring_designer: designer }

      its(:referrals) { should have(1).item }

      its("referrals.first") { should include(status: :ko) }

    end

  end

end