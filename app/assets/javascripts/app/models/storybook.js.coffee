class App.Models.Storybook extends Backbone.Model
    paramRoot: 'storybook'
    schema:
      title:
        type:          "Text"
        title:         "Story Title"
        validators:    ["required"]
      price:
        title:         "Price"
        type:          "Currency"
        template:      "currencyField"
        validators:    ["required"]
      author:
        title:         "Author"
        type:           "Text"
        validators:    ["required"]
      description:
        title:         "Description"
        type:           "Text"
        validators:    ["required"]
      published_on:
        title:         "Date of Publishing"
        type:          "Date"
      android_or_ios:
        title:         "Mobile Platform"
        type:          "Buttons"
        buttonType:    "radio"
        labeling:      ["iOS", "Both", "Android"]
        selectedIndex: 1
#      tablet_or_phone:
#        type:          "Buttons"
#        buttonType:    "radio"
#        labeling:      ["Tablet", "Both", "Phone"]
#        selectedIndex: 1
      record_enabled:
        title:         "Enable voice recording?"
        help:          "Allows your users to record, use, and share voice-overs"
        type:          "Buttons"
        buttonType:    "radio"
        labeling:      ["On", "Off"]
        selectedIndex: 0

    url: ->
      '/storybooks/' + App.currentStorybook().get('id') + '.json'

    toJSON: ->
      @attributes

class App.Collections.StorybooksCollection extends Backbone.Collection
  model: App.Models.Storybook

  url: ->
    '/storybooks.json'

  # Sorting
  comparator: (storybook) ->
    date = new Date(storybook.get('created_at'));
    date
