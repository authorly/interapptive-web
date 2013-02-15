class App.Views.HotspotsIndex extends App.Views.AbstractFormView
   events: ->
     _.extend({}, super, {
       'change select#on_touch': "populateAssets"
     })

   template: JST['app/templates/touch_zones/index']

   initialize: (options) ->
     @widget = options.widget if options?.widget
     @storybook = options.storybook

     @collections =
       videos: @storybook.videos
       sounds: @storybook.sounds
     super


   render: ->
     @$el.html(@template(widget: @widget))
     @$el.find('#touch_zones.modal-body').append @form.el
     @attachDeleteButton() if @widget?.id
     this


   attachDeleteButton: ->
     $button = $('<button />', {
       'class': 'btn btn-primary btn-danger widget-delete',
       text: "Delete",
     })
     @form.$el.find('div.form-actions').prepend($button)


   delete: (e) =>
     @widget.collection.remove(@widget)
     @cancel(e)


   deleteMessage: ->
     "\nYou are about to delete this hotspot. This cannot be undone.\n\n\n" +
     "Are you sure you wish to continue?"


   formOptions: ->
     data: @widget
     schema:
       on_touch:
         type: 'Select'
         options: ['Select video or sound...', 'Show video', 'Play sound']
         title: "On touch"
       asset_id:
         type: 'Select'
         options: []
         title: "Media to play"



   updateAttributes: (event) =>
     event.preventDefault()
     touch_options = @prepareHashForWidget(@form.getValue())
     if @widget?.id
       @widget.set(touch_options)
     else
       App.vent.trigger('create:widget', _.extend(touch_options, {type: 'HotspotWidget'}))

     App.vent.trigger('modal-cancel')


   # Creates either sound_id or video_id key/value pair for passing to new touch widget
   prepareHashForWidget: (form_value) ->
     hash = {}
     hash[@keyForSelect[form_value.on_touch]] = form_value.asset_id
     hash


   keyForSelect:
     'Show video': 'video_id',
     'Play sound': 'sound_id',


   populateAssetsFor: (asset_type) ->
     $asset_ids = $('#asset_id').empty()
     _.each @collections[asset_type].models, (m) ->
       $asset_ids.append($('<option />').val(m.get 'url').text(m.get 'name'))


   populateAssets: (event) ->
     switch $(event.target).val()
       when 'Show video'
         @populateAssetsFor('videos')
       when 'Play sound'
         @populateAssetsFor('sounds')
       else
         $('#asset_id').html('<option></option>')
