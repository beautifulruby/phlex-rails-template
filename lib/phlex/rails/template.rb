# frozen_string_literal: true

require_relative "template/version"
require_relative "template/handler"

module Phlex
  module Rails
    module Template
      class Error < StandardError; end
    end
  end
end

require_relative "template/engine" if defined?(Rails)