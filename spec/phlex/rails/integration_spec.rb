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
    ActionView::Template.register_template_handler :phlex, Phlex::Rails::Template::Handler

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

    File.write(File.join(@view_path, "test", "implicit.html.phlex"), 'h1 { @message }')
    File.write(File.join(@view_path, "test", "explicit.html.phlex"), 'div { @message }')

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

  it "allows custom configurator class" do
    # Create custom configurator
    class PrefixConfigurator < Phlex::Rails::Template::Configurator
      def assign_variables
        view_context.assigns.each do |key, value|
          component.instance_variable_set(:"@#{key}", "PREFIX: #{value}")
        end
      end
    end
    
    # Register custom configurator for :phlex handler
    Phlex::Rails::Template.register :phlex, PrefixConfigurator

    # Create view
    File.write(File.join(@view_path, "test", "prefixed.html.phlex"), 'span { @message }')

    # Create controller action
    TestController.class_eval do
      def prefixed
        @message = "Test"
        render "test/prefixed"
      end
    end

    controller = TestController.new
    controller.request = ActionDispatch::TestRequest.create
    controller.response = ActionDispatch::TestResponse.new

    controller.process(:prefixed)
    expect(controller.response.body).to include("<span>PREFIX: Test</span>")
  ensure
    # Reset to default configurator
    Phlex::Rails::Template.register :phlex, Phlex::Rails::Template::Configurator
  end

  it "allows register with block" do
    # Register with block
    Phlex::Rails::Template.register :phlex do
      def assign_variables
        view_context.assigns.each do |key, value|
          component.instance_variable_set(:"@#{key}", "BLOCK: #{value}")
        end
      end
    end

    # Create view
    File.write(File.join(@view_path, "test", "blocked.html.phlex"), 'span { @message }')

    # Create controller action
    TestController.class_eval do
      def blocked
        @message = "Test"
        render "test/blocked"
      end
    end

    controller = TestController.new
    controller.request = ActionDispatch::TestRequest.create
    controller.response = ActionDispatch::TestResponse.new

    controller.process(:blocked)
    expect(controller.response.body).to include("<span>BLOCK: Test</span>")
  ensure
    # Reset to default configurator
    Phlex::Rails::Template.register :phlex, Phlex::Rails::Template::Configurator
  end
end
