require 'spec_helper'

describe Designer  do

  let(:designer)  { FactoryGirl.create :designer }

  subject { designer }

  describe 'autocorrect dribbble username' do

    let(:dribbble_username) { 'AndrewCoyleDesign' }

    it 'corrects usernames starting with http://dribbble.com' do
      designer.dribbble_username = "http://dribbble.com/#{dribbble_username}"
      designer.save
      designer.reload.dribbble_username.should == dribbble_username
    end

    it 'corrects usernames starting with https://dribbble.com' do
      designer.dribbble_username = "https://dribbble.com/#{dribbble_username}"
      designer.save
      designer.reload.dribbble_username.should == dribbble_username
    end

    it 'leaves correct dribbble username unchanged' do
      designer.dribbble_username = dribbble_username
      designer.save
      designer.reload.dribbble_username.should == dribbble_username
    end

  end

  describe 'autocorrect twitter username' do

    let(:twitter_username) { 'AndrewCoyleDesign' }

    it 'corrects usernames starting with http://twitter.com/' do
      designer.twitter_username = "http://twitter.com/#{twitter_username}"
      designer.save
      designer.reload.twitter_username.should == twitter_username
    end

    it 'corrects usernames starting with https://twitter.com/' do
      designer.twitter_username = "https://twitter.com/#{twitter_username}"
      designer.save
      designer.reload.twitter_username.should == twitter_username
    end

    it 'corrects usernames starting with @' do
      designer.twitter_username = "@#{twitter_username}"
      designer.save
      designer.reload.twitter_username.should == twitter_username
    end

    it 'leaves correct username unchanged' do
      designer.twitter_username = twitter_username
      designer.save
      designer.reload.twitter_username.should == twitter_username
    end

  end

  describe 'autocorrect behance username' do

    let(:behance_username) { 'AndrewCoyleDesign' }

    it 'corrects usernames starting with http://www.behance.net/' do
      designer.behance_username = "http://www.behance.net/#{behance_username}"
      designer.save
      designer.reload.behance_username.should == behance_username
    end

    it 'corrects usernames starting with https://www.behance.net/' do
      designer.behance_username = "https://www.behance.net/#{behance_username}"
      designer.save
      designer.reload.behance_username.should == behance_username
    end

    it 'corrects usernames starting with https://behance.net/' do
      designer.behance_username = "https://behance.net/#{behance_username}"
      designer.save
      designer.reload.behance_username.should == behance_username
    end

    it 'leaves correct username unchanged' do
      designer.behance_username = behance_username
      designer.save
      designer.reload.behance_username.should == behance_username
    end

  end

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

  describe 'for_skill scope' do

    let!(:illustration_designer) { FactoryGirl.create :designer, skills_budgets: { illustration: { icon_design: 2000, illustration: 3000 }}}
    let!(:webdesign_designer)    { FactoryGirl.create :designer, skills_budgets: { web_design: {} } }
    let!(:webdesign_designer2)   { FactoryGirl.create :designer, skills: [ :web_design ] }

    it 'returns illustration designer' do
      Designer.for_skill(:illustration).should have(1).item
      Designer.for_skill(:illustration).first.should == illustration_designer
    end

    it 'returns webdesign designer' do
      Designer.for_skill(:web_design).should have(2).items
      Designer.for_skill(:web_design).first.should == webdesign_designer
      Designer.for_skill(:web_design).last.should == webdesign_designer2
    end

  end

end
