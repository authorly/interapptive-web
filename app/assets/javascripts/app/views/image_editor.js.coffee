class Backbone.Form.editors.Image extends Backbone.Form.editors.Base

  tagName: 'div'

  # so Backbone Forms does not add one item to empty arrays, by default
  @isAsync: true


  initialize: ->
    super
    if @model?
      @collection = @model.storybook.images
      @setValue @model.get(@key)
    else
      @collection = @options.list.model.storybook.images
      @setValue @value


  render: () ->
    selector = new App.Views.ImageSelector
      image: @collection.get @getValue()
      collection: @collection
      selectedImageViewClass: 'SelectedSprite'
      className: 'selector'
    selectorEl = selector.render().$el
    selectorEl.prepend selectorEl.find('.selected-image')
    @listenTo selector, 'select', (image) ->
      @setValue image?.id
      @trigger 'change', @

    @$el.append selectorEl
    # because we need to use `isAsync`, we simulate a 'ready'
    window.setTimeout (=> @trigger 'readyToAdd', @), 0

    @


  getValue: ->
    @image_id


  setValue: (value) ->
    @image_id = value

