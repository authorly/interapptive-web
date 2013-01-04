class App.Views.KeyframeTextIndex extends Backbone.View

  initialize: ->
    @texts = []

    $(window).on 'resize',  @resize



  render: ->
    # RFCTR: Should be triggered by event
    @removeTexts()

    # RFCTR: Should be a triggered event
    for keyframeText in @collection.models
      keyframe = App.keyframesCollection.get keyframeText.get('keyframe_id')
      keyframeText = new App.Views.TextWidget(model: keyframeText)
      @addText(keyframeText)
      App.storybookJSON.addText(keyframeText, keyframe)

    #
    # RFCTR:
    #     Aforementioned RFCTR'd method should trigger this,
    #     Or call it inside of the triggered method
    #
    @resize()


  # RFCTR: Should be a triggered event
  removeTexts: ->
    $(text.el).remove() for text in @texts

    @texts.length = 0


  # RFCTR: Unused? Remove *after* verifying non-usage
  deselectTexts: ->
    text.deselect() for text in @texts


  updateText: ->
    # RFCTR: Doesn't belong here, belongs to model layer
    @collection.fetch success: => @render()


  addText: (text) ->
    @$el.append text.render().el
    @texts.push(text)


  # RFCTR this is not used?
  editText: (text) ->
    # RFCTR: Should be on text widget
    for _text in @texts
      if _text isnt text then _text.disableEditing()


  resize: =>
    @position(text) for text in @texts


  # RFCTR move this to each text view
  position: (text) ->
    text.setPosition text.model.get('x_coord'), text.model.get('y_coord')


  createText: (string) ->
    attributes =
      keyframe_id : App.currentKeyframe().get 'id'
      content     : string

    @collection.create attributes,
      success: (keyframeText, response) =>
        #
        # RFCTR:
        #     Entire callback needs ventilation;
        #     should blow App.vent.trigger 'text_widget:element_created'
        #
        # @dira 2013-01-03: do other parts of the app need to know about this?
        # If not, this view should simply listen to `add` on `@collection` to do
        # the rendering of the new element.
        #
        textWidget = new App.Views.TextWidget(model: keyframeText)

        #
        # RFCTR:
        #     Text Widget should inhale and do the following
        #
        textWidget.fromToolbar = true
        App.currentKeyframeText(textWidget)
        # the random position should be set on the server, so we don't need
        # an additional save
        textWidget.setPosition 400*Math.random(), 350*Math.random()
        textWidget.save()
        @addText(textWidget)
        textWidget.editTextWidget()
        textWidget.enableEditing()
