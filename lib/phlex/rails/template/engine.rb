# frozen_string_literal: true

module Phlex
  module Rails
    module Template
      class Engine < ::Rails::Engine
        initializer "phlex.rails.template.register_handler" do
          ActiveSupport.on_load(:action_view) do
            ActionView::Template.register_template_handler :phlex, Phlex::Rails::Template::Handler
          end
        end
      end
    end
  end
end