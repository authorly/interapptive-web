class App.Views.BackgroundSoundForm extends App.Views.AbstractFormView
  events: ->
    _.extend({}, super, {})


  updateAttributes: (event) ->
    event.preventDefault()

    errors = @form.commit()
    return if errors

    @model.save {},
      success: =>
        App.trackUserAction 'Saved background sound'
        App.vent.trigger 'has_background_sound:scene', @model.hasBackgroundSound()
        App.vent.trigger 'hide:modal'


  formOptions: ->
    form_schema =
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
          validators:    [
            checkRepetation = (value, formValues) ->
              err =
                type: "sound_repeat_count"
                message: "Must use 0 or 1."

              err if value < 0 or value > 1
          ]

    if @model.isMainMenu()
      form_schema['schema']['sound_effect_id'] =
        type: "Select"
        help: "Sound effect that plays one time when Main Menu is shown."
        options: [{ val: null, label: "None" }].concat(_.map(@model.storybook.sounds.models, (s) -> { val: s.id, label: s.toString() } ))
        title: "Sound Effect"

    form_schema
