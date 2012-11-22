class App.Views.KeyframeTextIndex extends Backbone.View

  texts : []
  
  initialize: ->
    @collection.on('reset', @render, this)
    $(window).on('resize', @resize)
      
  render: ->
    @removeTexts()
    
    for keyframeText in @collection.models
      parentKeyframe = App.keyframesCollection.get keyframeText.get('keyframe_id')

      keyframeText = new App.Views.TextWidget(model: keyframeText)
      @addText(keyframeText)
      App.storybookJSON.addText(keyframeText, parentKeyframe)

    @resize()
    
  removeTexts: ->
    # remove text widgets
    for t in @texts
      $(t.el).remove()
    @texts.length = 0
    
  deselectTexts: ->
    for t in @texts
      t.deselect()
      
  updateText: ->
    @collection.fetch success: =>
      @render()
      
  addText: (text) ->
    $(@el).append(text.render().el)
    @texts.push(text)
  
  editText: (text) ->
    # turn off previously edited text and re-enable dragging
    for t in @texts
      if t isnt text
        t.disableEditing()
        t.enableDragging()
      
  createText: (str) ->
    attributes =
      keyframe_id : App.currentKeyframe().get('id')
      content : str
      
    @collection.create attributes,
      success: (keyframeText, response) =>
        text = new App.Views.TextWidget(model: keyframeText)
        text.fromToolbar = true
        App.currentKeyframeText(keyframeText)
        text.setPositionFromCocosCoords(400*Math.random(), 350*Math.random())
        text.save()
        @addText(text)
        App.editTextWidget(text)
        text.enableEditing()


  resize: =>
    # position texts
    for t in @texts
      @positionText(t)
      t.constrainToCanvas()
    
  #position text based on canvas position, solving for cocos2 canvas x,y
  positionText: (text) ->
    canvas = $('#builder-canvas')
    text.setPositionFromCocosCoords(text.model.get('x_coord'), text.model.get('y_coord'))
    
  leave: ->
    #TODO remove events
    
