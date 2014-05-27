class App.Models.SubscriptionPublishInformation extends Backbone.Model
  schema:
    cover_image_id:
      type: 'Image'
      title: 'Cover Image'
      # TODO text
      help: "The image to use for this storybook on the subscription platform"
      validators: [
        (value, formValues) ->
          required = {
            type: 'cover_image_id',
            message: "can't be blank"
          }

          if value? then null else required
      ]
      fieldClass: 'imageEditor'


  url: ->
    "/storybooks/#{@storybook.id}/subscription_publish_information.json"


  isNew: ->
    false


  toJSON: ->
    _.pick super, 'cover_image_id'


  valid: ->
    @get('cover_image_id')?
