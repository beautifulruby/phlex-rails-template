# frozen_string_literal: true

module Phlex
  module Rails
    module Template
      class Handler
        def self.call(template, source = nil)
          src = source || template.source
          handler_name = template.short_identifier[/\.(\w+)\z/, 1]&.to_sym || :phlex

          <<~RUBY
            __component__ = Phlex::Rails::Template.build(self, :#{handler_name}) do
              #{src}
            end
            __component__.render_in(self).to_s
          RUBY
        end
      end
    end
  end
end
