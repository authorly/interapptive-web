class App.Views.KeyframeIndex extends Backbone.View
  template: JST["app/templates/keyframes/index"]
  
  tagName: 'ul'
  
  className: 'keyframe-list'
 
  events:
    'click .keyframe-list li div': 'setAsActive'
    
  setAsActive: (e) ->
    $(e.currentTarget).parent().siblings().removeClass("active")
    $(e.currentTarget).parent().removeClass("active")
    $(e.currentTarget).parent().addClass("active")
    
  initialize: ->
    @collection.on('reset', @render, this)
    
  render: ->
    @collection.each(@appendKeyframe)
    this

  appendKeyframe: (keyframe) ->
    view = new App.Views.Keyframe(model: keyframe)
    $('.keyframe-list').append(view.render().el)


    $(".keyframe-list li").removeClass "active"
    $(".keyframe-list li").first().addClass "active"

