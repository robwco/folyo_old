class OffersAndProjectSkills < Mongoid::Migration
  def self.up
    Designer.all.pull(:skills, :print_design)
    Designer.where(skills: :logo_design).push(:skills, :logo_and_identity_design)
    Designer.all.pull(:skills, :logo_design)
    Designer.where(skills: :mobile_design).and(:skills.ne => :UI_design).push(:skills, :UI_design)
    Designer.all.pull(:skills, :mobile_design)
  end

  def self.down
  end
end