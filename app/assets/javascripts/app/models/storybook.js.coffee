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

  url: ->
    if @isNew() then return '/storybooks.json'
    '/storybooks/' + App.currentStorybook().get("id") + '.json'

  toJSON: ->
    @attributes

class App.Collections.StorybooksCollection extends Backbone.Collection
  model: App.Models.Storybook

  url: ->
    '/storybooks.json'

  comparator: (storybook) ->
    new Date(storybook.get('created_at'))
