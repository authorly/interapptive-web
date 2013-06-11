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
      title:         "Story Title"
      validators:    ["required",
                       checkTitle = (value, formValues) ->
                         err =
                           type: "title"
                           message: "Oops! Title must be 2-25 characters"

                         err  if value.length < 2 or value.length > 25
                      ]

    price:
      title:         "Price"
      type:          "Currency"
      template:      "currencyField"
      validators:    ["required",
        checkPrice = (value, formValues) ->
          err =
            type: "price"
            message: "Must be non-negative and less than $100.00"

          err  if value < 0 or value > 100
        ]

    author:
      title:         "Author"
      type:           "Text"
      validators:    ["required",
        checkAuthor = (value, formValues) ->
          err =
            type: "author"
            message: "Oops! Author field must be 2-25 characters."

          err  if value.length < 3 or value.length > 50
      ]

    description:
      title:         "Description"
      type:           "Text"
      validators:    ["required",
        checkDesc = (value, formValues) ->
          err =
            type: "description"
            message: "App description must be 10-25 characters."

          err  if value.length < 3 or value.length > 25
      ]

    pageFlipTransitionDuration:
      title: 'Page flipping animation duration'
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
      title: 'Fade in/out duration, when swiping to the next/previous keyframe'
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
      title: 'Additional delay before going to the next scene in autoplay mode'
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
      title: 'Additional delay before going to the next keyframe in autoplay mode'
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
    @fonts  = new App.Collections.FontsCollection( [], storybook: @)

    @widgets.on 'change', => @save()


  baseUrl: ->
    url = '/storybooks'
    url += "/#{@id}" unless @isNew()
    url


  url: ->
    @baseUrl() + '.json'


  toJSON: ->
    _.extend super, widgets: @widgets.toJSON()


  fetchCollections: ->
    # TODO use deferreds to load assets in parallel and load scenes afterwards
    @images.fetch(async: false, reset: true)
    @sounds.fetch(async: false, reset: true)
    @videos.fetch(async: false, reset: true)
    @fonts.fetch(async: false, reset: true)
    @scenes.fetch(reset: true)


  addNewScene: ->
    @scenes.addNewScene()


  hasCustomFonts: ->
    @customFonts().length > 0


  customFonts: ->
    @_customFonts ||= @fonts.subcollection
      filter: (font) -> !font.isSystem()
      childOptions:
        models: []
        storybook: @


  compile: (platform) ->
    $.post('/compiler',
      storybook_json: JSON.stringify(new App.JSON(@).app)
      storybook_id: @get('id')
      platform: platform
      ->
        App.vent.trigger('show:message', 'success', "Your application is under compilation. You will shortly receive a link to download your compiled application via email.")
    'json')


class App.Collections.StorybooksCollection extends Backbone.Collection
  model: App.Models.Storybook

  url: ->
    '/storybooks.json'

  comparator: (storybook) ->
    new Date(storybook.get('created_at'))
