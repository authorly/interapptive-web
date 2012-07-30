class App.Views.KeyframeTextIndex extends Backbone.View
  
  texts : []
  
  initialize: ->
    @collection.on('reset', @render, this)
    $(window).on('resize', @resize)
      
  render: ->
    @removeTexts()
    
    for c in @collection.models
      console.log "KeyframeTextIndex create TextWidget"
      text = new App.Views.TextWidget(model: c)
      @addText(text)
    @resize()
    
  removeTexts: ->
    #remove text widgets, clean up
    for t in @texts
      $(t.el).remove()
      #TODO may need to clean up the text object itself with leave() or something similar 
    @texts.length = 0
      
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
      
  createText: () ->
    text = new App.Views.TextWidget(string: (prompt('Enter some text') or '<No Text>'))
    #TODO center it
    _canvas = $('#builder-canvas')
    text.setPositionFromCocosCoords(300, 350)
    
    @collection.create
      keyframe_id : App.currentKeyframe().get('id')
      content : text.getText()
      x_coord : text.getCocosPosition().x
      y_coord : text.getCocosPosition().y
      face : text.fontFace()
      size : text.fontSize()
      color : text.fontColor()
      success: (collection, response) =>
        #TODO need to add model to text
    @addText(text)

  resize: =>
    # position texts
    for t in @texts
      @positionText(t)
    
  #position text based on canvas position, solving for cocos2 canvas x,y
  positionText: (text) ->
    _canvas = $('#builder-canvas')
    text.setPositionFromCocosCoords(text.model.get('x_coord'), text.model.get('y_coord'))
    
  leave: ->
    #TODO remove events
    