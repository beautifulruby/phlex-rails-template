# Phlex::Rails::Template

A Rails template handler that lets you write Phlex components directly in `.html.phlex` view files.

## Installation

Run the following command from the root of your Rails project:

```ruby
# Make sure you've installed phlex-rails
bundle add 'phlex-rails-template'
```

## Usage

Create view files with the `.html.phlex` extension:

```ruby
# app/views/posts/show.html.phlex
h1 { @post.title }

div(class: "content") do
  p { @post.body }
end
```

In your controller:

```ruby
class PostsController < ApplicationController
  def show
    @post = Post.find(params[:id])
    # Renders app/views/posts/show.html.phlex automatically
  end
end
```

Controller instance variables are automatically available in your templates.

## Configuration

You can customize how components are instantiated and how variables are assigned by passing a block to `register`:

```ruby
# config/initializers/phlex_rails_template.rb
Phlex::Rails::Template.register :phlex do
  # Override the base component class
  def component_class
    ApplicationComponent
  end

  # Override to instantiate the component with custom arguments
  def create_component(component_class)
    component_class.new(view_context.session, request: view_context.request)
  end

  # Override to customize how controller variables are assigned
  def assign_variables
    view_context.assigns.each do |key, value|
      component.instance_variable_set(:"@#{key}", "PREFIX: #{value}")
    end
  end
end
```

Or you can pass a configurator class directly:

```ruby
class CustomConfigurator < Phlex::Rails::Template::Configurator
  def component_class
    ApplicationComponent
  end
end

Phlex::Rails::Template.register :phlex, CustomConfigurator
```

You can also register additional template handlers with different configurators:

```ruby
Phlex::Rails::Template.register :customrb, MyCustomConfigurator
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
