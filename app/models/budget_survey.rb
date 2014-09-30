class BudgetSurvey < Survey

  def on_submit
    if user._type == 'Designer'
      user.skills_budgets = {}

      if self.logo_budget || self.full_identity_budget
        user.skills_budgets[:logo_identity_design] = {}
        user.skills_budgets[:logo_identity_design][:logo] = self.logo_budget.to_f if self.logo_budget
        user.skills_budgets[:logo_identity_design][:full_identity] = self.full_identity_budget.to_f if self.full_identity_budget
      end

      if self.illustration_budget || self.icon_design_budget
        user.skills_budgets[:illustration] = {}
        user.skills_budgets[:illustration][:illustration] = self.illustration_budget.to_f if self.illustration_budget
        user.skills_budgets[:illustration][:icon_design] =  self.icon_design_budget.to_f  if self.icon_design_budget
      end

      if self.coming_soon_budget || self.landing_page_budget || self.simple_website_budget || self.complex_website_budget
        user.skills_budgets[:web_design] = {}
        if self.coming_soon_budget
          user.skills_budgets[:web_design][:coming_soon] = {}
          user.skills_budgets[:web_design][:coming_soon][:no_coding] = self.coming_soon_budget.to_f
          user.skills_budgets[:web_design][:coming_soon][:coding] = self.coming_soon_coding_budget.to_f if self.coming_soon_coding_budget
        end
        if self.landing_page_budget
          user.skills_budgets[:web_design][:landing_page] = {}
          user.skills_budgets[:web_design][:landing_page][:no_coding] = self.landing_page_budget.to_f
          user.skills_budgets[:web_design][:landing_page][:coding] = self.landing_page_coding_budget.to_f if self.landing_page_coding_budget
        end
        if self.simple_website_budget
          user.skills_budgets[:web_design][:simple_website] = {}
          user.skills_budgets[:web_design][:simple_website][:no_coding] = self.simple_website_budget.to_f
          user.skills_budgets[:web_design][:simple_website][:coding] = self.simple_website_coding_budget.to_f if self.simple_website_coding_budget
        end
        if self.complex_website_budget
          user.skills_budgets[:web_design][:complex_website] = {}
          user.skills_budgets[:web_design][:complex_website][:no_coding] = self.complex_website_budget.to_f
          user.skills_budgets[:web_design][:complex_website][:coding] = self.complex_website_coding_budget.to_f if self.complex_website_coding_budget
        end
      end

      if self.simple_mobile_app_budget || self.complex_mobile_app_budget || self.simple_web_app_budget || self.complex_web_app_budget
        user.skills_budgets[:UI_design] = {}
        user.skills_budgets[:UI_design][:simple_mobile_app] =  self.simple_mobile_app_budget.to_f  if self.simple_mobile_app_budget
        user.skills_budgets[:UI_design][:complex_mobile_app] = self.complex_mobile_app_budget.to_f if self.complex_mobile_app_budget
        if self.simple_web_app_budget
          user.skills_budgets[:UI_design][:simple_web_app] = {}
          user.skills_budgets[:UI_design][:simple_web_app][:no_coding] = self.simple_web_app_budget.to_f
          user.skills_budgets[:UI_design][:simple_web_app][:coding] = self.simple_web_app_coding_budget.to_f if self.simple_web_app_coding_budget
        end
        if self.complex_web_app_budget
          user.skills_budgets[:UI_design][:complex_web_app] = {}
          user.skills_budgets[:UI_design][:complex_web_app][:no_coding] = self.complex_web_app_budget.to_f
          user.skills_budgets[:UI_design][:complex_web_app][:coding] = self.complex_web_app_coding_budget.to_f if self.complex_web_app_coding_budget
        end
      end

      if self.animated_trailer_budget
        user.skills_budgets[:motion_design] = {}
        user.skills_budgets[:motion_design][:animated_trailer] = self.animated_trailer_budget.to_f
      end


      if self.ux_consulting_budget || self.ux_research_budget || self.information_architecture_budget
        user.skills_budgets[:UX_design] = {}
        user.skills_budgets[:UX_design][:UX_consulting] =            self.ux_consulting_budget.to_f            if self.ux_consulting_budget
        user.skills_budgets[:UX_design][:UX_research] =              self.ux_research_budget.to_f              if self.ux_research_budget
        user.skills_budgets[:UX_design][:information_architecture] = self.information_architecture_budget.to_f if self.information_architecture_budget
      end

      user.save!
    end
  end

end