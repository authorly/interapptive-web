class App.Views.SortableKeyframeText extends Backbone.View
  template:   JST['app/templates/keyframes_text/sortable_keyframe_text']

  tagName:    'li'

  className: 'sortable-keyframe-text'


  render: ->
    @$el.html(@template(keyframe_text: @model)).
      attr 'id', "keyframetext_#{@model.id}"

    @
