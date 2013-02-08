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

                         err  if value.length < 3 or value.length > 25
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

    android_or_ios:
      title:         "Mobile Platform"
      type:          "Buttons"
      buttonType:    "radio"
      labeling:      ["iOS", "Both", "Android"]
      selectedIndex: 1

    record_enabled:
      title:         "Voice recording?"
      help:          "Allows your users to record and share voiceovers"
      type:          "Buttons"
      buttonType:    "radio"
      labeling:      ["On", "Off"]
      selectedIndex: 0


  initialize: ->
    @scenes = new App.Collections.ScenesCollection([], storybook: @)
    @images = new App.Collections.ImagesCollection([], storybook: @)
    @images.fetch(async: false) # needed to have access to the images when rendering sprites
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


  fetchScenes: ->
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


class App.Collections.StorybooksCollection extends Backbone.Collection
  model: App.Models.Storybook

  url: ->
    '/storybooks.json'

  comparator: (storybook) ->
    new Date(storybook.get('created_at'))
