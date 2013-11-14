class App.Models.ApplicationInformation extends Backbone.Model
  @contentDescriptionSchema: ->
    schema = {}
    _.each [ 'fantasy_violence', 'realistic_violence', 'sexual_content', 'profanity', 'drugs', 'mature', 'gambling', 'horror', 'prolonged_violence', 'graphical_sexual_content'], (category) ->
      schema[category] =
        type: 'Radio'
        options: [
          { val: 'none',    label: 'None' },
          { val: 'mild',    label: 'Infrequent/Mild' },
          { val: 'intense', label: 'Frequent/Intense' },
        ]
    schema

  schema:
    available_from:
      type: 'Date'
      yearStart: (new Date).getFullYear()
      yearEnd: (new Date).getFullYear() + 100
      validators: ['required',
        (value, formValues) ->
          err = {
            type: 'available_from',
            message: 'The application should be available starting on a date in the future'
          }

          now = new Date
          today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
          if value < today then err else null
      ]
    price_tier:
      type: 'Select'
      options: _.map [1..15], (tier) -> val: "tier_#{tier}", label: "$#{tier-1}.99"
    content_description:
      type: 'Object'
      subSchema: @contentDescriptionSchema()
    for_kids:
      type: 'Checkbox'
      title: 'Made for kids?'
    description:
      type: 'Text'
      validators: [
        (value, formValues) ->
          err = {
            type: 'description',
            message: 'Descriptions cannot be longer than 4000 characters.'
          }

          if value.length > 4000 then err else null
      ]
    keywords:
      type: 'Text'
      validators: [
        (value, formValues) ->
          err = {
            type: 'keywords',
            message: 'Keywords cannot be longer than 100 characters.'
          }

          if value.length > 100 then err else null
      ]


  parse: (attributes={}) ->
    @storybook ||= attributes?.storybook
    delete attributes.storybook

    attributes


  url: ->
    "/storybooks/#{@storybook.id}/application_information.json"
