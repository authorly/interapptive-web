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

    published_on:
      title:         "Published on"
      type:          "Date"
    android_or_ios:
      title:         "Mobile Platform"
      type:          "Buttons"
      buttonType:    "radio"
      labeling:      ["iOS", "Both", "Android"]
      selectedIndex: 1

    # tablet_or_phone:
    #   type:          "Buttons"
    #   buttonType:    "radio"
    #   labeling:      ["Tablet", "Both", "Phone"]
    #   selectedIndex: 1

    record_enabled:
      title:         "Enable voice recording?"
      help:          "Allows your users to record, use, and share voice-overs"
      type:          "Buttons"
      buttonType:    "radio"
      labeling:      ["On", "Off"]
      selectedIndex: 0

  url: ->
    '/storybooks/' + App.currentStorybook().get("id") + '.json'

  toJSON: ->
    @attributes

class App.Collections.StorybooksCollection extends Backbone.Collection
  model: App.Models.Storybook

  url: ->
    '/storybooks.json'

  # Sorting
  comparator: (storybook) ->
    new Date(storybook.get('created_at'))
