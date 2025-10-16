# frozen_string_literal: true

require "spec_helper"
require "rails"
require "action_controller/railtie"
require "action_view/railtie"
require "phlex"
require "phlex-rails"

RSpec.describe "Rails integration" do
  before(:all) do
    # Minimal Rails app
    class TestApp < Rails::Application
      config.eager_load = false
      config.secret_key_base = "test"
      config.logger = Logger.new(nil)
    end

    TestApp.initialize!

    # Register the handler
    ActionView::Template.register_template_handler :rb, Phlex::Rails::Template::Handler

    # Base Phlex component
    module Views
      class Base < Phlex::HTML
        include Phlex::Rails::Helpers
      end
    end

    # Controller
    class TestController < ActionController::Base
      def implicit
        @message = "Hello"
      end

      def explicit
        @message = "World"
        render "test/explicit"
      end
    end

    # Set up views
    @view_path = File.expand_path("../fixtures/views", __FILE__)
    FileUtils.mkdir_p(File.join(@view_path, "test"))

    File.write(File.join(@view_path, "test", "implicit.html.rb"), 'h1 { @message }')
    File.write(File.join(@view_path, "test", "explicit.html.rb"), 'div { @message }')

    TestController.prepend_view_path(@view_path)
  end

  after(:all) do
    FileUtils.rm_rf(File.expand_path("../fixtures", __FILE__))
  end

  it "renders implicit view" do
    controller = TestController.new
    controller.request = ActionDispatch::TestRequest.create
    controller.response = ActionDispatch::TestResponse.new

    controller.process(:implicit)
    expect(controller.response.body).to include("<h1>Hello</h1>")
  end

  it "renders explicit view" do
    controller = TestController.new
    controller.request = ActionDispatch::TestRequest.create
    controller.response = ActionDispatch::TestResponse.new

    controller.process(:explicit)
    expect(controller.response.body).to include("<div>World</div>")
  end

  it "allows custom base_class configuration" do
    # Create custom base class
    class CustomBase < Phlex::HTML
      include Phlex::Rails::Helpers
    end

    # Configure handler to use custom base
    original_base = Phlex::Rails::Template.base_class
    Phlex::Rails::Template.base_class = "CustomBase"

    # Create view that uses custom base
    File.write(File.join(@view_path, "test", "custom.html.rb"), 'p { "Custom" }')

    # Create controller action
    TestController.class_eval do
      def custom
        render "test/custom"
      end
    end

    controller = TestController.new
    controller.request = ActionDispatch::TestRequest.create
    controller.response = ActionDispatch::TestResponse.new

    controller.process(:custom)
    expect(controller.response.body).to include("<p>Custom</p>")
  ensure
    Phlex::Rails::Template.base_class = original_base
  end
end
