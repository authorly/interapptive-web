class App.Views.BackgroundSoundForm extends App.Views.AbstractFormView
  events: ->
    _.extend({}, super, {})


  updateAttributes: (event) ->
    event.preventDefault()

    errors = @form.commit()
    return if errors

    @model.save {},
      success: =>
        App.vent.trigger 'has_background_sound:scene', @model.hasBackgroundSound()
        App.vent.trigger 'hide:modal'


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
        title: "Loop sound?"
        help: "Enter \"0\" to play once or \"1\" to loop continuously."
        validators:    [
          checkRepetation = (value, formValues) ->
            err =
              type: "sound_repeat_count"
              message: "Must use 0 or 1."

            err if value < 0 or value > 1
        ]
