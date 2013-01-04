class App.Views.SceneForm extends App.Views.AbstractFormView
  events: ->
    _.extend({}, super, {})


  formOptions: ->
    model: @getModel()

    schema:
      sound_id:
        type: "Select"
        options: App.soundsCollection
        title: "Background Sound"

      sound_repeat_count:
        type: "Number"
        title: "Repetation count"
        help: "0 for infinite"
        validators:    [
          checkRepetation = (value, formValues) ->
            err =
              type: "sound_repeat_count"
              message: "Must be non-negative"

            err  if value < 0
          ]


  getModel: ->
    @model = App.currentScene()


  initialize: ->
    super


  deleteMessage: ->
    '\nYou are about to delete this scene\n\n\n' +
    'This cannot be undone.\n\n\n' +
    'Are you sure you want to continue?\n'
