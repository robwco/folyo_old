class AR::Evaluation < ActiveRecord::Base

  self.table_name = 'evaluations'

  ## associations ##
  belongs_to :job_offer
  belongs_to :designer
  belongs_to :user

  ## validations ##
  #validates_presence_of :job_offer, :user, :designer

  ## callbacks ##
  #after_create :send_notification!

  ## scopes ##
  #scope :ordered, :order => 'created_at DESC'

  ## methods ##

  def designer
    @designer ||= self.user.designer
  end

  def client
    @client ||= self.job_offer.client
  end

  def self.create_or_update_evaluations(job_offer, evaluations_by_designer_user_id, comment)
    evaluations_by_designer_user_id.each do |id, evaluation|
      if evaluation.blank?
        eval = Evaluation.find_by_job_offer_id_and_user_id(job_offer.id, id)
        eval.destroy unless eval.nil?
      else
        eval = Evaluation.find_or_initialize_by_job_offer_id_and_user_id(job_offer.id, id)
        eval.evaluation = evaluation
        eval.comment = comment
        eval.save!
      end
    end
  end

  # def send_notification!
  #   ClientMailer.job_offer_replied(self).deliver
  # end

end
