# frozen_string_literal: true

require "forwardable"

require_relative "template/version"
require_relative "template/registry"
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
        
        def build(component_class, &template_block)
          @component = component_class.new
          assign_variables
          component
        end
      end
      
      @registry = Registry.new
      
      class << self
        extend Forwardable
        
        attr_reader :registry
        
        def_delegators :registry, :register, :build
      end
    end
  end
end

require_relative "template/engine" if defined?(Rails)