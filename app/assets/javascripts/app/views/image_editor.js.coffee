class Backbone.Form.editors.Image extends Backbone.Form.editors.Base

  tagName: 'div',

  # events:
      # 'change': function() {
          # // The 'change' event should be triggered whenever something happens
          # // that affects the result of `this.getValue()`.
          # this.trigger('change', this);
      # },
      # 'focus': function() {
          # // The 'focus' event should be triggered whenever an input within
          # // this editor becomes the `document.activeElement`.
          # this.trigger('focus', this);
          # // This call automatically sets `this.hasFocus` to `true`.
      # },
      # 'blur': function() {
          # // The 'blur' event should be triggered whenever an input within
          # // this editor stops being the `document.activeElement`.
          # this.trigger('blur', this);
          # // This call automatically sets `this.hasFocus` to `false`.
      # }

  initialize: ->
    super
    @collection = @model.storybook.images
    @setValue @model.get(@key)


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

    @$el.append selectorEl

    @


  getValue: ->
    @image_id


  setValue: (value) ->
    @image_id = value


# Notes:

# The editor must implement getValue(), setValue(), focus() and blur() methods.
# The editor must fire change, focus and blur events.
# The original value is available through this.value.
# The field schema can be accessed via this.schema. This allows you to pass in custom parameters.
