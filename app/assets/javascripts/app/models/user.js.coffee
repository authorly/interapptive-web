class App.Models.User extends Backbone.Model
  paramRoot: 'user'

  url: ->
    '/users/' + this.get('id')
