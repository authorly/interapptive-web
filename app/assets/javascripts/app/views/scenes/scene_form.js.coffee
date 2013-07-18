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

      loop_sound:
        type: "Checkbox"
        title: "Loop sound?"
