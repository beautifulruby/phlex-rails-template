# frozen_string_literal: true

module Phlex
  module Rails
    module Template
      class Registry
        def initialize
          @handlers = {}
          @component_classes = {}
        end
        
        def register(handler_name, configurator_class = nil, &block)
          if block_given?
            @handlers[handler_name] = Class.new(Configurator, &block)
          else
            @handlers[handler_name] = configurator_class
          end
        end
        
        def configurator_class_for(handler_name)
          @handlers[handler_name] || Configurator
        end
        
        def build(view_context, handler_name, cache_key, &template_block)
          configurator_class = configurator_class_for(handler_name)
          configurator = configurator_class.new(view_context)
          
          # Cache the component class per template
          component_class = @component_classes[cache_key] ||= Class.new(configurator.component_class) do
            define_method(:view_template, &template_block)
          end
          
          configurator.build(component_class, &template_block)
        end
      end
    end
  end
end