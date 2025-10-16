# frozen_string_literal: true

require_relative "template/version"
require_relative "template/handler"
require_relative "template/engine"

module Phlex
  module Rails
    module Template
      class Error < StandardError; end
    end
  end
end