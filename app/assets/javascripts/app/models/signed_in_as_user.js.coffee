#= require ./user
class App.Models.SignedInAsUser extends App.Models.User

  url: ->
    '/user/show_signed_in_as_user'
