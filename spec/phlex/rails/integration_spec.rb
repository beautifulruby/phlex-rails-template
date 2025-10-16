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

  let(:controller) do
    TestController.new.tap do
      it.request = ActionDispatch::TestRequest.create
      it.response = ActionDispatch::TestResponse.new
    end
  end

  it "renders implicit view" do
    controller.process(:implicit)
    expect(controller.response.body).to include("<h1>Hello</h1>")
  end

  it "renders explicit view" do
    controller.process(:explicit)
    expect(controller.response.body).to include("<div>World</div>")
  end
end
