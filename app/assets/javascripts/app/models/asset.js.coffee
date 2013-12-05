##
# A collection of assets.
class App.Collections.AssetsCollection extends App.Lib.AggregateCollection

  initialize: (models, attributes) ->
    super
    @storybook = attributes.storybook


  url: ->
     "/storybooks/#{@storybook.id}/assets.json"


  model: (attrs, options) ->
    new App.Models[attrs.type](attrs, options)


  add: (model, options={}) ->
    if options.fromMember
      super
    else
      collection = switch model.type
        when 'Image' then @storybook.images
        when 'Sound' then @storybook.sounds
        when 'Video' then @storybook.videos
      collection?.add model


  fetchMissing: ->
    @fetch
      remove: false
      data:
        except_ids: @pluck('id')
