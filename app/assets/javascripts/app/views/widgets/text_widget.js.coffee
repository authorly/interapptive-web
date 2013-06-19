##
# HTML/CSS 'overlay' view for when editing a text widget.
# Uses contentEditable
#
class App.Views.TextWidget extends Backbone.View
  className: 'text-widget'

  events:
    'input': 'input'
    'keydown': 'keydown'

  ESCAPE_KEYCODE = 27

  ENTER_KEYCODE = 13

  SCALE = 0.494


  initialize: ->
    @model = @options.widget.model
    @model.on 'change:font_color', @setFontColor
    @model.on 'change:font_size', @setFontSize
    @model.on 'change:font_face', @setFontFamily

    App.vent.on 'activate:scene', @deselect
    App.currentSelection.on 'change:keyframe', @deselect


  render: ->
    @


  input: ->
    return App.Lib.LinebreakFilter.filter(@$el)


  keydown: (event) ->
    switch event.keyCode
      when ENTER_KEYCODE
        @shouldSave = true
        @deselect()
      when ESCAPE_KEYCODE
        @deselect()


  initializeEditing: ->
    @enableContentEditable()
    @setFontFamily()
    @setFontSize()
    @setElementString()
    @setFontColor()
    @setPosition()
    @selectText()


  deselect: =>
    if @shouldSave
      @model.set('string', @$el.text())
      @shouldSave = false

    App.vent.trigger 'done_editing:text_widget', @model

    @remove()


  setElementString: ->
    @$el.text @model.get('string')


  setFontColor: =>
    rgb = @model.get('font_color')
    @$el.css "color", "rgb(#{rgb.r}, #{rgb.g}, #{rgb.b})"


  setFontFamily: =>
    @$el.css('font-family', @model.get('name'))


  setFontSize: =>
    @$el.css("font-size",  "#{@model.get('font_size')}px")


  setPosition: ->
    @$el.css
      'left': @_absolutePositionFromWidgetCoords().left
      'top': @_absolutePositionFromWidgetCoords().top


  enableContentEditable: ->
    @$el.attr('contentEditable', 'true')


  selectText: ->
    @$el.selectText()
    @$el.focus()


  _absolutePositionFromWidgetCoords: =>
    origin = @options.workspaceOrigin

    padding =
      left: @$el.outerWidth() - @$el.width() + 6
      bottom: @$el.outerHeight() - @$el.innerHeight() + 1

    position =
      top:
        origin.top - @model.get('position').y * SCALE + padding.bottom - @$el.height()
      left:
        origin.left + @model.get('position').x * SCALE - padding.left

    position
