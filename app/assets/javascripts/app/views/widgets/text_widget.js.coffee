##
# HTML/CSS 'overlay' view for when editing a text widget.
# Uses contentEditable
#
class App.Views.TextWidget extends Backbone.View
  className: 'text-widget'

  events:
    'keydown': 'keydown'


  CANVAS_ID = 'builder'


  initialize: ->
    #
    # canvas.attr('height') is scale of HTML canvas
    #  element as set by the attribute on the element
    #
    # canvas.height() is the actual size of the canvas
    #  after being scaled with CSS.
    #
    canvas = $('#' + CANVAS_ID)
    @canvasScale = canvas.height() / canvas.attr('height')

    @model = @options.widget.model
    @listenTo @model, 'change:position',          @setPosition
    @listenTo @model, 'change:font_color',        @fontColorChanged
    @listenTo @model, 'change:visual_font_color', @setFontColor
    @listenTo @model, 'change:font_size',         @setFontSize
    @listenTo @model, 'change:font_id',           @setFontFamily

    App.vent.on 'activate:scene', @deselect
    App.currentSelection.on 'change:keyframe', @deselect


  render: ->
    @


  keydown: (event) ->
    switch event.keyCode
      when App.Lib.KeyCodes.enter
        @shouldSave = true
        @deselect()
      when App.Lib.KeyCodes.escape
        @shouldSave = false
        @deselect()


  initializeEditing: ->
    @enableContentEditable()
    @setFontFamily()
    @setFontSize()
    @setElementString()
    @fontColorChanged()
    @setPosition()
    @selectText()


  deselect: =>
    if @shouldSave
      text = @$el.text()
      if $.trim(text).length > 0
        @model.set('string', @$el.text())
      else
        @model.collection?.remove(@model)
        removed = true
      @shouldSave = false

    @trigger 'done' unless removed?

    @remove()


  setElementString: ->
    @$el.text @model.get('string')


  fontColorChanged: ->
    rgb = @model.get('font_color')
    @setFontColor(rgb)


  setFontColor: (rgb) ->
    @$el.css "color", "rgb(#{rgb.r}, #{rgb.g}, #{rgb.b})"


  setFontFamily: ->
    @$el.css('font-family', @model.font())


  setFontSize: ->
    @$el.css("font-size",  "#{@model.get('font_size')}px")
    @setPosition() # update position to keep it vertically centered


  setPosition: ->
    canvasHalfWidth = 292
    # TODO how to get border in Firefox
    margin =
      left: -canvasHalfWidth + (@model.get('position').x - parseFloat(@$el.css('padding-left')) - parseFloat(@$el.css('border-left-width'))) * @canvasScale
      top:  ( -@model.get('position').y - parseFloat(@$el.css('padding-top')) - parseFloat(@$el.css('border-top-width'))) * @canvasScale - @$el.height() * 0.5
    @$el.css
      'margin-left': "#{Math.round(margin.left)}px"
      'margin-top':  "#{Math.round(margin.top)}px"


  enableContentEditable: ->
    @$el.attr('contentEditable', 'true')


  selectText: ->
    @$el.selectText()
    @$el.focus()
