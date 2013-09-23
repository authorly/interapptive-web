##
# Relations:
# * `@scenes`. It has many scenes. A Backbone collection.
# * `@images`. It has many images. A Backbone collection.
# * `@sounds`. It has many sounds. A Backbone collection.
# * `@videos`. It has many videos. A Backbone collection.
# * `@fonts`.  It has many fonts.  A Backbone collection.
# * @widgets. It has many widgets. A Backbone collection.
class App.Models.Storybook extends Backbone.Model
  schema:
    title:
      type:          "Text"
      title:         "Storybook Title"
      validators:    ["required",
                       checkTitle = (value, formValues) ->
                         err =
                           type: "title"
                           message: "Oops! Title must be 2-25 characters"

                         err  if value.length < 2 or value.length > 25
                      ]

    pageFlipTransitionDuration:
      title: 'Page flip duration'
      help: 'seconds'
      type:  'Number'
      validators:    ["required",
        mustBeNumber = (value, formValues) ->
          err =
            type: "pageFlipTransitionDuration"
            message: "Must be a positive number"

          err if (Number(value) + "" != value + "") or value < 0
      ]

    paragraphTextFadeDuration:
      title: 'Text fade duration'
      help: 'seconds'
      type:  'Number'
      validators:    ["required",
        mustBeNumber = (value, formValues) ->
          err =
            type: "paragraphTextFadeDuration"
            message: "Must be a positive number"

          err if (Number(value) + "" != value + "") or value < 0
      ]

    autoplayPageTurnDelay:
      title: 'Extra delay before page turn in autoplay'
      help: 'seconds'
      type:  'Number'
      validators:    ["required",
        mustBeNumber = (value, formValues) ->
          err =
            type: "autoplayPageTurnDelay"
            message: "Must be a positive number"

          err if (Number(value) + "" != value + "") or value < 0
      ]

    autoplayKeyframeDelay:
      title: ''
      title: 'Additional delay between text in autoplay'
      help: 'seconds'
      type:  'Number'
      validators:    ["required",
        mustBeNumber = (value, formValues) ->
          err =
            type: "autoplayKeyframeDelay"
            message: "Must be a positive number"

          err if (Number(value) + "" != value + "") or value < 0
      ]


  parse: (attributes={}) ->
    widgets = attributes.widgets; delete attributes.widgets
    if @widgets?
      @widgets.set  (widgets) if widgets?
    else
      @widgets = new App.Collections.Widgets(widgets)
      @widgets.storybook = @

    attributes


  initialize: (attributes) ->
    @parse(attributes)

    @scenes = new App.Collections.ScenesCollection([], storybook: @)
    @images = new App.Collections.ImagesCollection([], storybook: @)
    @sounds = new App.Collections.SoundsCollection([], storybook: @)
    @videos = new App.Collections.VideosCollection([], storybook: @)
    @videos.on 'add reset', @videosChanged, @
    @fonts  = new App.Collections.FontsCollection( [], storybook: @)

    @widgets.on 'change', => @save()


  baseUrl: ->
    url = '/storybooks'
    url += "/#{@id}" unless @isNew()
    url


  url: ->
    @baseUrl() + '.json'


  toJSON: ->
    json = super
    delete json.preview_image_url
    json.widgets = @widgets.toJSON()
    json


  fetchCollections: ->
    # TODO use deferreds to load assets in parallel and load scenes afterwards
    $.when(
      @images.fetch(),
      @sounds.fetch(),
      @videos.fetch(),
      @fonts .fetch()
    ).then( =>
      # 2013-09-20 @dira
      # TODO Use `reset: true` until the fix for backbone#2513 is released.
      # https://github.com/jashkenas/backbone/issues/2513
      @scenes.fetch(reset: true)
    )


  addAsset: (asset) ->
    if asset instanceof App.Models.Image
      @images.add(asset)
    else if asset instanceof App.Models.Sound
      @sounds.add(asset)
    if asset instanceof App.Models.Video
      @videos.add(asset)


  videosChanged: ->
    @videos.pollUntilTranscoded()


  addNewScene: ->
    @scenes.addNewScene()


  hasCustomFonts: ->
    @customFonts().length > 0


  defaultFont: ->
    @_defaultFont ||= @fonts.where(asset_type: 'system', name: 'Arial')[0]


  customFonts: ->
    @_customFonts ||= @fonts.subcollection
      filter: (font) -> !font.isSystem()
      childOptions:
        models: []
        storybook: @


  voiceoverNeeded: ->
    menu = @scenes.detect (scene) -> scene.isMainMenu()
    rtm  = menu.widgets.detect (w) -> w.get('name') == 'read_to_me'
    auto = menu.widgets.detect (w) -> w.get('name') == 'auto_play'
    !(rtm.get('disabled')? and auto.get('disabled')?)


  canBeCompiled: ->
    @videos.length == 0 or @videos.hasOnlyTranscodedVideos()


  compile: (platform) ->
    if @canBeCompiled()
      $.post('/compiler',
        storybook_json: JSON.stringify(new App.JSON(@).app)
        storybook_id: @get('id')
        platform: platform
        ->
          App.vent.trigger('show:message', 'success', "Your application is under compilation. You will shortly receive a link to download your compiled application via email.")
      'json')
    else
      App.vent.trigger('show:message', 'info', 'Some of the videos that you uploaded are still being transcoded. Please compile your application once the transcoding is complete.')


class App.Collections.StorybooksCollection extends Backbone.Collection
  model: App.Models.Storybook

  url: ->
    '/storybooks.json'

  comparator: (storybook) ->
    new Date(storybook.get('created_at'))
