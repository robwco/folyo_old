class MigrateOffersAndDesignersToMarkdown < Mongoid::Migration
  def self.up
    JobOffer.all.each do |offer|
      offer.designer_replies.each do |reply|
        reply.message = reply.message.truncate(350)
        reply.save!
      end
    end

    Designer.where(_type: 'Html::Designer').each(&:to_markdown!)
    JobOffer.where(_type: 'Html::JobOffer').each(&:to_markdown!)
  end

  def self.down
  end
end