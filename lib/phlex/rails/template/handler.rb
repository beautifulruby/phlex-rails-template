# frozen_string_literal: true

module Phlex
  module Rails
    module Template
      class Handler
        def self.call(template, source = nil)
          src = source || template.source

          <<~RUBY
            # Define an anonymous subclass of your Phlex base
            __phlex_class__ = Class.new(#{Phlex::Rails::Template.base_class}) do
              def view_template
                #{src}
              end
            end

            # Instantiate
            __phlex_instance__ = __phlex_class__.new

            # Copy controller assigns (only user-defined ivars) into the component.
            # Prefer `view_assigns` (Rails filters internals), fallback to `assigns`.
            __assigns__ = respond_to?(:view_assigns) ? view_assigns : assigns
            __assigns__.each do |k, v|
              __ivar__ = :"@\#{k}"
              if __phlex_instance__.instance_variable_defined?(__ivar__)
                raise ArgumentError,
                  "Refusing to overwrite \#{__ivar__} on \#{__phlex_class__}. "\
                  "It was already set by the component before assigns were applied."
              end
              __phlex_instance__.instance_variable_set(__ivar__, v)
            end

            # Render
            __phlex_instance__.render_in(self).to_s
          RUBY
        end
      end
    end
  end
end
