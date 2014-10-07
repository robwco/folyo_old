class SkillsRenaming < Mongoid::Migration

  def self.up
    puts "Designer skills"
    Designer.all.pull(skills: :print_design)
    Designer.where(skills: :logo_design).push(skills: :logo_and_identity_design)
    Designer.all.pull(skills: :logo_design)
    Designer.where(skills: :mobile_design).and(:skills.ne => :UI_design).push(skills: :UI_design)
    Designer.all.pull(skills: :mobile_design)

    puts "Job Offers skills"
    JobOffer.all.pull(skills: :print_design)
    JobOffer.where(skills: :logo_design).push(skills: :logo_and_identity_design)
    JobOffer.all.pull(skills: :logo_design)
    JobOffer.where(skills: :mobile_design).and(:skills.ne => :UI_design).push(skills: :UI_design)
    JobOffer.all.pull(skills: :mobile_design)

    puts "Designer projects skills"
    Designer.where('projects.0' => {'$exists' => true}).each do |designer|
      designer.projects.each do |project|
        project.skills.delete(:print_design)
        project.skills.map!{|skill| skill == :logo_design ? :logo_and_identity_design : skill}
        if project.skills.include?(:mobile_design)
          project.skills.delete(:UI_design)
          project.skills.map!{|skill| skill == :mobile_design ? :UI_design : skill}
        end
      end
      designer.save
    end
  end

  def self.down
  end
end