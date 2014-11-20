class BudgetSurveyData

  class << self

    def skills
      @skills = nil if Rails.env.development?
      if @skills.nil?
        yaml = YAML.load_file(File.join(Rails.root, 'config', 'surveys', 'budget.yml'))
        @skills = ActiveSupport::OrderedHash.new
        yaml.each do |skill|
          @skills[skill[:key]] = skill.tap {|skill| skill.delete(:key)}
        end
      end
      @skills
    end

    def skills_with_statistics
      json = skills
      skills.each do |skill, skill_content|
        skill_content[:project_types].each do |project_type, project_type_content|
          json[skill][:project_types][project_type][:pricing] = statistics_for(skill, project_type)
        end
      end
      json
    end

    private

    def statistics_for(skill, project_type)
      budgets = Designer
        .where(:"skills_budgets.#{skill}.#{project_type}".ne => nil)
        .pluck(:skills_budgets)
        .map{|budget| budget[skill][project_type] }

      first_budget = budgets.first
      if first_budget.nil? || first_budget.kind_of?(Float)
        aggregate_budgets(budgets)
      else
        option_keys = first_budget.keys
        option_keys.inject({}) do |h, key|
          budgets_for_option = budgets.map{|budgets| budgets[key] }.compact
          h[key.to_sym] = aggregate_budgets(budgets_for_option)
          h
        end
      end
    end

    def aggregate_budgets(budgets)
      budgets.uniq.sort{|a, b| a <=> b }.map do |budget|
        {
          price: budget,
          percentile: budgets.percentile_rank(budget).round(2),
          count: budgets.count(budget)
        }
      end
    end

  end

end