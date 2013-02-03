class App.Views.SceneForm extends App.Views.AbstractFormView
  events: ->
    _.extend({}, super, {})


  formOptions: ->
    model: @model

    schema:
      sound_id:
        type: "Select"
        options: @model.storybook.sounds
        title: "Background Sound"

      sound_repeat_count:
        type: "Number"
        title: "Repetition count"
        help: "0 for infinite"
        validators:    [
          checkRepetation = (value, formValues) ->
            err =
              type: "sound_repeat_count"
              message: "Must be non-negative"

            err  if value < 0
          ]
