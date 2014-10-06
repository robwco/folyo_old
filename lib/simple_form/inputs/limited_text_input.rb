#module SimpleForm
#  module Inputs
    class LimitedTextInput < SimpleForm::Inputs::TextInput

      def input
        validators = object.class.validators_on(attribute_name.to_sym)

        if validator = validators.find_all{|v| v.is_a?(Mongoid::Validatable::LengthValidator)}.first
          if max = validator.options[:maximum]
            input_html_options[:class].append(:limited).append("limited-#{max}".to_sym)
          end
        end

        @builder.text_area(attribute_name, input_html_options)
      end

    end
#  end
#end