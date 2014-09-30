class ChangeDesignerSkills < Mongoid::Migration
  def self.up
    count = Designer.count
    max_budget = 10000.0

    Designer.where(skills: :ui_design).push(:skills, :UI_design)
    Designer.all.pull(:skills, :ui_design)

    Designer.all.each do |d|
      puts "#{count} designers to go"
      d.skills_budgets = {}
      if d.skills.include?(:web_design)
        d.skills_budgets[:web_design] = {
          coming_soon: { coding: max_budget, no_coding: max_budget },
          landing_page: { coding: max_budget, no_coding: max_budget },
          simple_website: { coding: max_budget, no_coding: max_budget },
          complex_website: { coding: max_budget, no_coding: max_budget }
        }
      end
      if d.skills.include?(:UI_design) || d.skills.include?(:mobile_design)
        d.skills_budgets[:UI_design] = {
          simple_mobile_app: max_budget,
          complex_mobile_app: max_budget
        }
        if d.skills.include?(:UI_design)
          d.skills_budgets[:UI_design][:simple_web_app] = { coding: max_budget, no_coding: max_budget },
          d.skills_budgets[:UI_design][:complex_web_app] = { coding: max_budget, no_coding: max_budget }
        end
      end
      if d.skills.include?(:icon_design) || d.skills.include?(:illustration)
        d.skills_budgets[:illustration] = {}
        if d.skills.include?(:illustration)
          d.skills_budgets[:illustration][:illustration] = max_budget
        end
        if d.skills.include?(:icon_design)
          d.skills_budgets[:illustration][:icon_design] = max_budget
        end
      end
      if d.skills.include?(:logo_design)
        d.skills_budgets[:logo_and_identity_design] = { logo: max_budget, full_identity: max_budget}
      end
      if d.skills.include?(:UX_design)
        d.skills_budgets[:UX_design] = {UX_consulting: max_budget, UX_research: max_budget, information_architecture: max_budget }
      end
      d.save
      count -= 1
    end
  end

  def self.down
  end
end