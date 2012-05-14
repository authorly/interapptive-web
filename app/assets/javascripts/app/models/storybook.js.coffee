class App.Models.Storybook extends Backbone.Model
    # Properties for backbone-forms to map w/ API
    # These must match column names

    schema:
      title:
        type:          "Text"
        validators:    ["required"]
      price:
        type:          "Currency"
        template:      "currencyField"
        validators:    ["required"]
      author:
        type:           "Text"
        validators:    ["required"]
      description:
        type:           "Text"
        validators:    ["required"]
      published_on:
        type:          "Date"
      android_or_ios:
        type:          "Buttons"
        buttonType:    "radio"
        labeling:      ["iOS", "Both", "Android"]
        selectedIndex: 1
      tablet_or_phone: "Text"
      record_enabled:  "Checkbox"


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
