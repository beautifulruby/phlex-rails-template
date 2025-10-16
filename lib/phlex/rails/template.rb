# frozen_string_literal: true

require_relative "template/version"
require_relative "template/handler"

module Phlex
  module Rails
    module Template
      class Error < StandardError; end
      
      @base_class = "::Views::Base"
      
      class << self
        attr_accessor :base_class
      end
    end
  end
end

require_relative "template/engine" if defined?(Rails)