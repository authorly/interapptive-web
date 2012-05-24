(->
  Form = Backbone.Form
  Base = Form.editors.Number
  createTemplate = Form.helpers.createTemplate
  triggerCancellableEvent = Form.helpers.triggerCancellableEvent
  exports = {}
  exports.Currency = Base.extend(
    defaultValue: null
    initialize: (options) ->
      Base::initialize.call this, options
      @$el.attr "type", "text"
      @$el.attr "placeholder", "0.00"
      @$el.addClass "input-mini"

    onKeyPress: (event) ->
      return  if event.charCode is 0
      newVal = @$el.val() + String.fromCharCode(event.charCode)
      matches_currency_format = /^\d+(?:\.\d{0,2})?$/.test(newVal)
      event.preventDefault()  unless matches_currency_format

    getValue: ->
      value = @$el.val()
      (if value is "" then null else parseFloat(value, 10))

    setValue: (value) ->
      value = (if value is null then null else parseFloat(value, 10))
      Base::setValue.call this, value
  )
  _.extend Form.editors, exports
)()