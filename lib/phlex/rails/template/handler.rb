# frozen_string_literal: true

module Phlex
  module Rails
    module Template
      class Handler
        def self.call(template, source = nil)
          src = source || template.source

          <<~RUBY
            __component__ = Phlex::Rails::Template.build(self, :phlex) do
              #{src}
            end
            __component__.render_in(self).to_s
          RUBY
        end
      end
    end
  end
end
