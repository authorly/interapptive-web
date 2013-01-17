# This is responsible for displaying all the TextWidgets
# in currently selected Keyframe on canvas. This uses
# App.Views.TextWidget to form views for individual
# TextWidget on the Keyframe and keeps track of all of
# those in @texts array.
#
# This view is useful when carrying out operation on
# TextWidgets of currently selected Keyframe. e.g.
# when Keyframe or Scene are switched.
class App.Views.TextWidgetIndex extends Backbone.View

  initialize: ->
    @texts = []
    $(window).on 'resize',  @resize

  render: ->
    for text_widget in @model.widgetsByType('TextWidget')
      @addText(new App.Views.TextWidget(widget: text_widget))
      # Following should be moved to TextWidget after creation code
      # Care should be taken to include the same when we bootstrap
      # the App json at the time of storybook load
      # App.storybookJSON.addText(keyframeText, keyframe)

    @resize()


  empty: ->
    @removeTexts()


  hide: ->
    text.$el.hide() for text in @texts


  show: ->
    text.$el.show() for text in @texts


  removeTexts: ->
    @$el.html('')
    @texts.length = 0


  addText: (text) ->
    @$el.append(text.render().el)
    @texts.push(text)


  disableOtherTextWidgetViewsThan: (text) ->
    for _text in @texts
      if _text isnt text then _text.disableEditing()


  resize: =>
    _.each(@texts, (t) -> t.position())


  createText: (text_widget) ->
    text_widget_view = new App.Views.TextWidget(widget: text_widget, fromToolbar: true)
    text_widget_view.position()
    @addText(text_widget_view)
    text_widget_view.editTextWidget()
    text_widget_view.enableEditing()


  removeText: (text_widget) ->
    text_widget_view = _.detect(@texts, (wv) -> wv.widget.id == text_widget.id)
    return unless text_widget_view?
    text_widget_view.remove()
    @texts.splice(@texts.indexOf(text_widget_view), 1)
