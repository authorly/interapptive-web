# Use PUT for PATCH requests
# TODO remove when we upgrade to Rails 4
Backbone._originalSync = Backbone.sync
Backbone.sync = (method, model, options) ->
  options.type = 'PUT' if method == 'patch'
  Backbone._originalSync(method, model, options)
