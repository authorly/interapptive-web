(->
  Form = Backbone.Form
  Base = Form.editors.Base
  createTemplate = Form.helpers.createTemplate
  triggerCancellableEvent = Form.helpers.triggerCancellableEvent
  exports = {}
  exports.Buttons = Base.extend(
    tagName: "div"
    className: "btn-group"
    events:
      "click .btn-primary": "setActive"

    initialize: (options) ->
      Base::initialize.call this, options
      @value = "both"  unless @value

    render: ->
      $el = @$el
      schema = @schema
      buttonType = schema.buttonType
      labeling = schema.labeling
      selectedIndex = schema.selectedIndex
      buttonTypeCssClass = undefined

    getValue: ->
      $(".active", @el).contents()

    setValue: (value) ->
      $(".active", @el).contents().val value

    setActive: (ev) ->
      ev.preventDefault()
      $(ev.target).siblings().removeClass "active"
      $(ev.target).addClass "active"
      @setValue $(ev.target).text()

    _arrayToHtml: (array, indexOfActive) ->
      html = []
      self = this
      _.each array, (option, index) ->
        is_active = (if index is indexOfActive then true else false)
        button_html = "<button class=\"btn btn-primary" + (if is_active is true then " active" else "") + "\">" + option + "</button>"
        self.setValue option  if is_active is true
        html.push button_html

      html.join ""
  )
  _.extend Form.editors, exports
)()