class App.Models.User extends Backbone.Model

  url: ->
    '/users/' + this.get('id')
