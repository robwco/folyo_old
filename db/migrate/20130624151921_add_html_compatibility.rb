class AddHtmlCompatibility < Mongoid::Migration

  def self.up
    JobOffer.update_all         '_type' => 'Html::JobOffer'
    Client.update_all           '_type' => 'Html::Client'
    DesignerReply.update_all    '_type' => 'Html::DesignerReply'
    FolyoEvaluation.update_all  '_type' => 'Html::FolyoEvaluation'

    Designer.where(:long_bio.ne => nil).update_all '_type' => 'Html::Designer'
  end

  def self.down
  end

end