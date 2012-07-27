class App.Views.KeyframeTextsIndex extends Backbone.View
  template: JST["app/templates/keyframestext/index"]
  
  initialize: ->
    console.log "KeyframeTextsIndex initialize"
    console.log @el
    console.log @collection
    @collection.on('reset', @render, this)
    #@collection.fetch
      #success: ->
        #console.log "KeyframeTextsIndex fetch success"
        #@render()
      
  render: ->
    console.log "KeyframeTextsIndex render"
    console.log @collection
    #console.log App.currentKeyframe()
    $(@el).html("")
    for c in @collection
      view = new App.Views.TextWidget(collection: c)
      $(@el).append(view.render())
      
  resize: ->
    # reposition texts