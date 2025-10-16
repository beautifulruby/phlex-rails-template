# frozen_string_literal: true

require_relative "template/version"
require_relative "template/handler"

module Phlex
  module Rails
    module Template
      class Error < StandardError; end
      
      class Configurator
        attr_reader :view_context, :component
        
        def initialize(view_context)
          @view_context = view_context
        end
        
        def component_class
          ::Views::Base
        end
        
        def create_component(component_class)
          component_class.new
        end
        
        def assign_variables
          assigns = view_context.respond_to?(:view_assigns) ? view_context.view_assigns : view_context.assigns
          assigns.each do |key, value|
            ivar = :"@#{key}"
            if component.instance_variable_defined?(ivar)
              raise ArgumentError,
                "Refusing to overwrite #{ivar} on #{component.class}. " \
                "It was already set by the component before assigns were applied."
            end
            component.instance_variable_set(ivar, value)
          end
        end
        
        def build(&template_block)
          klass = Class.new(component_class) do
            define_method(:view_template, &template_block)
          end
          
          @component = create_component(klass)
          assign_variables
          component
        end
      end
      
      @handlers = {}
      
      class << self
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
        
        def build(view_context, handler_name, &template_block)
          configurator_class = configurator_class_for(handler_name)
          configurator = configurator_class.new(view_context)
          configurator.build(&template_block)
        end
      end
    end
  end
end

require_relative "template/engine" if defined?(Rails)