# Framework.cr

The crystal web framework.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     framework:
       github: radbas/framework.cr
   ```

2. Run `shards install`

## Usage

```crystal
require "radbas-framework"
```

### Build an application and run it

```crystal
builder = Radbas::ApplicationBuilder.new
# Radbas::Context is an alias for :HTTP::Server::Context
builder.get "/", ->(ctx : Radbas::Context) {
  ctx.response.write "Hello World".to_slice
}

app : Radbas::Application = builder.build
server = Radbas::ApplicationServer.new app
server.listen

# Radbas::Application implements ::Http::Handler and can also be used as a HTTP::Server handler
server = HTTP::Server.new([app])
```

### Add middleware

```crystal
builder = Radbas::ApplicationBuilder.new

# Built-in middleware
builder.add_logging_middleware
builder.add_error_middleware # Gets added automatically, if not manually called
builder.add_routing_middleware # Gets added automatically, if not manually called

# Custom middleware
# Everything that satisfies Radbas::MiddlewareLike can be used as middleware
# Namely Proc(Radbas::Context, Radbas::Next, Nil) or Radbas::Middleware
class MyMiddleware
  include Radbas::Middleware
  def call(ctx : Radbas::Context, delegate : Radbas::Next)
    # before next
    delegate.call(ctx)
    # after next
  end
end

builder.add MyMiddleware.new

# middleware Proc
builder.add ->(ctx : Radbas::Context, del : Radbas::Next) {}
```

### Add routes

```crystal
# Everything that satisfies Radbas::ActionLike can be used as an endpoint
# Namely Proc(Radbas::Context, Nil) or Radbas::Action
class MyAction
  include Radbas::Action
  def call(ctx : Radbas::Context)
    ctx.response.write "Hello World".to_slice
  end
end

builder.get "/", MyAction.new
builder.get "/", ->(ctx : Radbas::Context) {}

# builder.post
# builder.put
# builder.patch
# builder.delete
# ...

# sever sent events
builder.sse "/events", ->(
  stream : Radbas::ServerSentEvents::Stream,
  ctx : Radbas::Context
) {}

# websocket
builder.ws "/socket", ->(
  socket : HTTP::WebSocket,
  ctx : Radbas::Context
) {}

 # TODO: full routing docs
```


## Contributing

1. Fork it (<https://github.com/radbas/framework.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Johannes Rabausch](https://github.com/jrabausch) - creator and maintainer
