class BudgetSurveyData

  class << self

    def skills
      {
        logo_and_identity_design: {
          name: 'Logo & Identity Design',
          project_types: {
            logo: {
              name: 'Logo Design',
              sample_project: {
                project_name: 'CoreFx Logo',
                author_name: 'Julien Renvoye',
                author_url: 'https://dribbble.com/JulienRenvoye',
                project_image: 'budgets/logo1.jpg',
                project_description: 'A clean, modern logo for a tech company. Included a short research phase, a few sketches, and a couple practical applications (business cards).',
                project_url: 'https://dribbble.com/shots/1569977-CoreFx-logo-design-process/attachments/241258'
              }
            },
            full_identity: {
              name: 'Full Identity Design',
              sample_project: {
                project_name: 'Gbox Studios',
                author_name: 'Bratus',
                author_url: 'http://bratus.co/',
                project_image: 'budgets/gbox.jpg',
                project_description: 'A full identity for a video production company, including a logo, icons, and packaging.',
                project_url: 'https://www.behance.net/gallery/18065083/Gbox-Studios-Brand-identity-'
              }
            }
          }
        },
        web_design: {
          name: 'Web Design',
          project_types: {
            coming_soon: {
              name: 'Coming Soon Page',
              options: ['No Coding', 'HTML/CSS Coding'],
              sample_project: {
                project_name: 'Snow Hippos',
                author_name: 'Martin Halik',
                author_url: 'http://martinhalik.cz/',
                project_image: 'budgets/snowhippos.jpg',
                project_description: 'A simple “coming soon” page with a few elements.',
                project_url: 'https://dribbble.com/shots/769460-Dont-be-lame-be-a-snow-hippo/attachments/191157'
              }
            },
            landing_page: {
              name: 'Landing Page',
              options: ['No Coding', 'HTML/CSS Coding'],
              sample_project: {
                project_name: 'Landing Page',
                author_name: 'Haraldur Thorleifsson',
                author_url: 'http://haraldurthorleifsson.com/',
                project_image: 'budgets/landingpage.jpg',
                project_description: 'A landing page introducing a product with an illustration, features, and explanatory copy.',
                project_url: 'https://dribbble.com/shots/934145-Landing-page-design/attachments/104293'
              }
            }
          }
        }
      }
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

      if budgets.first.kind_of?(Float)
        aggregate_budgets(budgets)
      else
        option_keys = budgets.first.keys
        option_keys.map do |key|
          budgets_for_option = budgets.map{|budgets| budgets[key] }.compact
          { key.to_sym => aggregate_budgets(budgets_for_option) }
        end
      end
    end

    def aggregate_budgets(budgets)
      budgets.sort{|a, b| a <=> b }.map do |budget|
        {
          price: budget,
          percentile: budgets.percentile_rank(budget).round(2),
          count: budgets.count(budget)
        }
      end
    end

  end

end