class App.Views.SceneForm extends App.Views.AbstractFormView
  events: ->
    _.extend({}, super, {})


  formOptions: ->
    model: @model

    schema:
      sound_id:
        type: "Select"
        help: "Each scene can have background audio specified."
        options: [{ val: null, label: "None" }].concat(_.map(@model.storybook.sounds.models, (s) -> { val: s.id, label: s.toString() } ))
        title: "Background Sound"

      sound_repeat_count:
        type: "Number"
        title: "Repetition count"
        help: "Enter \"0\" to loop selected audio continuously on this scene."
        validators:    [
          checkRepetation = (value, formValues) ->
            err =
              type: "sound_repeat_count"
              message: "Must be non-negative"

            err  if value < 0
          ]
