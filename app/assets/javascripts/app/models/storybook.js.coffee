##
# Relations:
# * `@scenes`. It has many scenes. A Backbone collection.
# * `@images`. It has many images. A Backbone collection.
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


  initialize: ->
    @scenes = new App.Collections.ScenesCollection([], storybook: @)
    @images = new App.Collections.ImagesCollection([], storybook: @)
    @sounds = new App.Collections.SoundsCollection([], storybook: @)
    @videos = new App.Collections.VideosCollection([], storybook: @)
    @fonts  = new App.Collections.FontsCollection([], storybook: @)


  url: ->
    if @isNew()
      '/storybooks.json'
    else
      "/storybooks/#{@id}.json"


  toJSON: ->
    @attributes


  fetchCollections: ->
    @images.fetch(async: false)
    @sounds.fetch(async: false)
    @videos.fetch(async: false)
    @fonts.fetch(async: false)
    @scenes.fetch()


  addNewScene: ->
    @scenes.addNewScene()


  compile: ->
    $.post('/compiler',
      storybook_json: App.storybookJSON.toString()
      storybook_id: @get('id')
      ->
        console.log('enqueued for compilation')
    'json')


  setIcon: (image_id, successCallback) ->
    $.post("/storybooks/#{@get('id')}/icon",
      image_id: image_id,
      ->,
      'json').success(successCallback)


class App.Collections.StorybooksCollection extends Backbone.Collection
  model: App.Models.Storybook

  url: ->
    '/storybooks.json'

  comparator: (storybook) ->
    new Date(storybook.get('created_at'))
