# Faraday::Lazyable
A request is never sent till a response have need.

## Installation
```
gem install faraday-lazyable
```

## Usage
```ruby
require "faraday-lazyable"

connection = Faraday.new do |connection|
  connection.use Faraday::Lazyable
  connection.adapter :net_http
  connection.response :logger
end

# A dummy response is returned.
response = connection.get("http://example.com")

# The HTTP request is sent when any method call happened to the response.
response.status #=> 200
```

## Example
Suppose that you are building a client web application for your API server.
Your controller sends HTTP request to the server.
You're trying to cache the HTTP request
by using [Fragment Cache](http://guides.rubyonrails.org/caching_with_rails.html) in the view layer
to improve performance.

### Controller
```ruby
class RecipesController < ApplicationController
  def show
    response = client.get("http://example.com/recipes/#{params[:id]}")
    @recipe = Recipe.new(response)
  end

  private

  def client
    Faraday.new
  end
end
```

### View
```erb
<% cache do %>
  <article class="recipe">
    <h1><%= @recipe.title %></h1>
    <p><%= @recipe.description %></p>
  </article>
<% end %>
```

### Problem
But you found that you cannot cache the HTTP request this way
because the HTTP request is already sent at the controller.

### Solution
Faraday::Lazyable fits this type of problem.
The response (`@recipe`) will become lazy-evaluated
and the HTTP request will never be sent till `@recipe.title` is called at the view.

```ruby
def client
  Faraday.new do |connection|
    connection.use Faraday::Lazyable
  end
end
```
