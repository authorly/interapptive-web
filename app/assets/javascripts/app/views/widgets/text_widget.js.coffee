##
# HTML/CSS 'overlay' view for when editing a text widget.
# Uses contentEditable
#
class App.Views.TextWidget extends Backbone.View
  template: JST["app/templates/widgets/text_widget_editor"]
  className: 'text-widget-editor'

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
    @listenTo @model, 'change:align',             @alignChanged
    @listenTo @model, 'change:font_color',        @fontColorChanged
    @listenTo @model, 'change:visual_font_color', @setFontColor
    @listenTo @model, 'change:font_size',         @setFontSize
    @listenTo @model, 'change:font_id',           @setFontFamily

    App.vent.on 'activate:scene', @deselect
    App.currentSelection.on 'change:keyframe', @deselect


  render: ->
    @$el.html @template()
    @$editable = @$('.editable')

    @


  keydown: (event) ->
    if event.keyCode == App.Lib.KeyCodes.escape
      @shouldSave = false
      @deselect()
    if event.keyCode == App.Lib.KeyCodes.enter && event.ctrlKey
      @shouldSave = true
      @deselect()


  initializeEditing: ->
    @setFontFamily()
    @setFontSize()
    @setElementString()
    @fontColorChanged()
    @alignChanged()
    @setPosition()
    @selectText()


  deselect: =>
    if @shouldSave
      text = @_getTextLines(@$editable).join("\n")
      if $.trim(text).length > 0
        @model.set string: text
        @model.set('string', text)
      else
        @model.collection?.remove(@model)
        removed = true
      @shouldSave = false

    @trigger 'done' unless removed?

    @remove()


  _getTextLines: (element) ->
    lines = []
    hadBr = false
    element.contents().each (__, c) =>
      if c.tagName == 'BR'
        if hadBr
          # skip the first <br/> in a sequence
          lines.push ''
        else
          hadBr = true
      else
        hadBr = false

        if c.tagName == 'DIV'
          innerLines = @_getTextLines($(c))
          innerLines = [''] if innerLines.length == 0
          lines.push innerLines...
        else if c.tagName == 'SPAN'
          lines.splice(lines.length - 1, 1, lines[lines.length - 1] + $(c).text())
        else if !c.tagName?
          lines.push $(c).text()
    _.map lines, (line) -> $.trim(line)


  setElementString: ->
    lines = @model.get('string').split('\n')
    html = _.map lines, (line) ->
      # add a breakline so that empty div break as well
      "<div>#{if line == '' then '<br/>' else line}</div>"
    @$editable.html html


  alignChanged: ->
    if @model.previous('align')?
      alignAsNumber =
        left: -1
        center: 0
        right: 1

      delta = alignAsNumber[@model.get('align')] - alignAsNumber[@model.previous('align')]
      if delta != 0
        position = @model.get('position')
        dx = @$editable.width() * delta * 0.5
        @model.set 'position',
          x: position.x + if dx < 0 then Math.floor(dx) else Math.ceil(dx)
          y: position.y

    @$el.removeClass('align-left').removeClass('align-center').removeClass('align-right').
      addClass "align-#{@model.get('align')}"
    @setPosition()


  fontColorChanged: ->
    rgb = @model.get('font_color')
    @setFontColor(rgb)


  setFontColor: (rgb) ->
    @$el.css "color", "rgb(#{rgb.r}, #{rgb.g}, #{rgb.b})"


  setFontFamily: ->
    @$el.css('font-family', @model.font())


  setFontSize: ->
    @$el.css("font-size",  "#{@model.get('font_size')}px")


  setPosition: ->
    canvasHalfWidth = 292

    margin =
      top: -@model.get('position').y * @canvasScale - parseFloat(@$editable.css('padding-top')) - parseFloat(@$editable.css('border-top-width'))
    switch @model.get('align')
      when 'left'
        margin.left  = -canvasHalfWidth + (@model.get('position').x - parseFloat(@$editable.css('padding-left')) - parseFloat(@$editable.css('border-left-width'))) * @canvasScale
      when 'center'
        margin.left  = -canvasHalfWidth + @model.get('position').x * @canvasScale
      when 'right'
        margin.right =  canvasHalfWidth - (@model.get('position').x + parseFloat(@$editable.css('padding-right')) - parseFloat(@$editable.css('border-right-width'))) * @canvasScale

    @$el.css
       'margin-top': "#{Math.round(margin.top)}px"
    if margin.left?
      @$el.css
       'margin-left': "#{Math.round(margin.left)}px"
    if margin.right?
      @$el.css
       'margin-right': "#{Math.round(margin.right)}px"


  selectText: ->
    if @model.get('string') == (new App.Models.TextWidget).get('string')
      @$editable.selectText()
    @$editable.focus()
