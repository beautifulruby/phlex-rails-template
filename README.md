# Phlex::Rails::Template

A Rails template handler that lets you write Phlex components directly in `.html.rb` view files.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'phlex-rails-template'
```

And then execute:

```bash
bundle install
```

## Setup

Create a base Phlex component class:

```ruby
# app/views/views/base.rb
module Views
  class Base < Phlex::HTML
  end
end
```

## Usage

Create view files with the `.html.rb` extension:

```ruby
# app/views/posts/show.html.rb
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
    # Renders app/views/posts/show.html.rb automatically
  end
end
```

Controller instance variables are automatically available in your templates.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).