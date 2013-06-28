FIRST_NAMES = ["James", "John", "Robert", "Michael", "William", "David", "Richard", "Charles", "Joseph", "Thomas", "Christopher", "Daniel", "Paul"]
LAST_NAMES = ["Smith", "Johnson", "Williams", "Jones", "Brown", "Davis", "Miller", "Wilson", "Moore", "Taylor", "Anderson", "Thomas", "Jackson", "White", "Harris", "Martin", "Thompson", "Garcia", "Martinez", "Robinson", "Clark", "Rodriguez"]
COMPANY_NAMES = ["ABC Telecom","Fake Brothers","QWERTY Logistics","Demo, inc.","Sample Company","Sample, inc","Acme Corp","Allied Biscuit","Ankh-Sto Associates","Extensive Enterprise","Galaxy Corp","Globo-Chem","Mr. Sparkle","Globex Corporation","LexCorp","LuthorCorp","North Central Positronics","Omni Consimer Products","Praxis Corporation","Sombra Corporation","Sto Plains Holdings","Tessier-Ashpool","Wayne Enterprises","Wentworth Industries","ZiffCorp","Bluth Company","Strickland Propane","Thatherton Fuels","Three Waters","Water and Power","Western Gas & Electric","Mammoth Pictures","Mooby Corp","Gringotts","Thrift Bank","Flowers By Irene","The Legitimate Businessmens Club","Osato Chemicals","Transworld Consortium","Universal Export","United Fried Chicken","Virtucon","Kumatsu Motors","Keedsler Motors","Powell Motors","Industrial Automation","Sirius Cybernetics Corporation","U.S. Robotics and Mechanical Men","Colonial Movers","Corellian Engineering Corporation"]
CITIES = ["New York","Los Angeles","Chicago","Houston","Philadelphia","Phoenix","San Antonio","San Diego","Dallas","San Jose","Jacksonville","Indianapolis","San Francisco","Austin","Columbus"]
STATES = ["AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA","HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"]
JOB_LEVELS = ['Junior', 'Senior', 'Experienced', 'Qualified']
JOB_PROJECT_TYPE = ['social network', 'twitter killer', 'facebook killer', 'search engine', 'photo sharing service']
COMP_AMOUNT_LIST = (40..120).to_a.collect {|n| n * 1000}

def rand_from_list(list)
  list[rand(list.size)]
end

def rand_str
  (0...18).map{ ('a'..'z').to_a[rand(26)] }.join
end

#modified from src: http://railstips.org/blog/archives/2007/04/29/lorem-ispum/
class RandomText
  # http://www.railstips.org/2007/4/29/lorem-ispum
  # lorem [number] [type] (ie: lorem 5 paragraphs/words/chars)
  def initialize(unit='words', max=2000)
    @lorem_unit = unit
    @max_lorems = max

    # load seed_text with a chank of static Lorem text
    @seed_text = Lorem::Base.new(@lorem_unit, @max_lorems).output
  end
  def output(max_output=0)
    out = @seed_text.split
    pos = rand(out.length - max_output)
    start_pos = (pos < 0 ? 0 : pos)
    end_pos = (pos + max_output > out.length ? out.length - max_output : pos + max_output)
    return out[start_pos...end_pos].join(" ")
  end
end
# src: http://stackoverflow.com/questions/3641057/rails-select-random-record
module ActiveRecord
  class Base
    def self.random
      if (c = count) != 0
        find(:first, :offset =>rand(c))
      end
    end
  end
end

FactoryGirl.define do
  sequence :email do |n|
    first_name = rand_from_list(FIRST_NAMES).downcase
    last_name = rand_from_list(LAST_NAMES).downcase
    domain = "#{rand_str.downcase}.com"
    "#{first_name}.#{last_name}#{n}@#{domain}"
  end
  sequence :full_name do |n|
    "#{rand_from_list(FIRST_NAMES)} #{rand_from_list(LAST_NAMES)}"
  end
  sequence :first_name do |n|
    rand_from_list(FIRST_NAMES)
  end
  sequence :last_name do |n|
    rand_from_list(LAST_NAMES)
  end
  sequence :url do |n|
    "http://#{rand_str.downcase}.com"
  end
  sequence :location do |n|
    "#{rand_from_list(CITIES)}, #{rand_from_list(STATES)}"
  end
  sequence :company_name do |n|
    rand_from_list(COMPANY_NAMES)
  end
  sequence :long_description do |n|
    RandomText.new('paragraphs').output(400).capitalize + "."
  end
  sequence :description do |n|
    RandomText.new('paragraphs').output(80).capitalize + "."
  end
  sequence :job_offer_title do |n|
    prefix_list = ["#{rand_from_list(JOB_LEVELS)} designer", "#{Designer.skills.sample.to_s.humanize}"]
    prefix = rand_from_list(prefix_list)
    job_type = rand_from_list(JOB_PROJECT_TYPE)
    "#{prefix} for a new #{job_type}"
  end
  sequence :compensation do |n|
    rand_from_list(COMP_AMOUNT_LIST)
  end
  sequence :created_at do |n|
    rand_from_list((5..25).to_a).days.ago.to_date
  end

  sequence :short_description do |n|
    RandomText.new('paragraphs').output(8).capitalize + "."
  end
  sequence :boolean do |n|
    [false, true][n%2]
  end
end

FactoryGirl.define do

  factory :job_offer do
    title {FactoryGirl.generate(:job_offer_title)}
    project_summary {FactoryGirl.generate(:description)}
    project_details {FactoryGirl.generate(:description)}
    compensation {FactoryGirl.generate(:compensation)}
    skills { [Designer.skills.sample, Designer.skills.sample] }
    budget_type { JobOffer.budget_types.sample }
    budget_range { JobOffer.budget_ranges.sample }
    status :accepted
    association :client
  end

  factory :order do
    transaction_id { rand_str }
  end

  factory :admin do |admin|
    email {FactoryGirl.generate(:email)}
    full_name {FactoryGirl.generate(:full_name)}
    password 'password'
    password_confirmation 'password'
  end

  factory :client do |client|
    email {FactoryGirl.generate(:email)}
    full_name {FactoryGirl.generate(:full_name)}
    password 'password'
    password_confirmation 'password'
    location {FactoryGirl.generate(:location)}
    company_name {FactoryGirl.generate(:company_name)}
    company_url {FactoryGirl.generate(:url)}
    company_description {FactoryGirl.generate(:description)}
  end

  factory :designer do |designer|
    email {FactoryGirl.generate(:email)}
    full_name {FactoryGirl.generate(:full_name)}
    password 'password'
    password_confirmation 'password'
    portfolio_url {FactoryGirl.generate(:url)}
    location {FactoryGirl.generate(:location)}
    short_bio {FactoryGirl.generate(:short_description)}
    long_bio {FactoryGirl.generate(:long_description)}
    twitter_username 'sachagreif'
    skype_username 'sachagreif'
    dribbble_username'sacha'
    linkedin_url 'http://fr.linkedin.com/in/sachagreif'
    behance_username 'SashaGreif'
  end

  factory :designer_reply do
    association :designer
    association :job_offer
    message 'a random message'
    picked false
    collapsed false
  end

  factory :folyo_evaluation do
    evaluation 'a random evaluation'
  end

end