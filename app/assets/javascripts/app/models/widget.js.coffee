class App.Models.Widget extends Backbone.Model
  # attributes: position(attributes: x, y) z_order
  @idGenerator = new App.Lib.Counter

  defaultPosition: ->
    x: 1024/2
    y: 768/2


  initialize: ->
    generator = App.Models.Widget.idGenerator
    if @id?
      generator.check(@id)
    else
      @set id: generator.next()


  canBeDeleted: ->
    @get('type') != 'ButtonWidget'


  canBeDisabled: ->
    return false unless @get('type') == 'ButtonWidget'
    name = @get('name')
    name == 'read_to_me' or name == 'auto_play'


  disabled: ->
    @get('disabled')


  disable: ->
    @set disabled: true


  enable: ->
    @set disabled: false


##
# A 'hotspot' widget, previously named touch zone. It has an associated
# video or sound (which will play when the hotspot is triggered).
#
class App.Models.HotspotWidget extends App.Models.Widget
  # attributes: radius action_id video_id sound_id
  MIN_RADIUS: 16

  defaults: ->
    type: 'HotspotWidget'
    radius: 48
    z_order: 5000
    position: @defaultPosition()


  asset: ->
    if @get('sound_id')
      @_storybook().sounds.get(@get('sound_id'))
    else if @get('video_id')
      @_storybook().videos.get(@get('video_id'))
    else
      null


  assetKey: ->
    if @get('sound_id')
      'sound_id'
    else if @get('video_id')
      'video_id'
    else
      null


  hasSound: ->
    @asset() instanceof App.Models.Sound


  hasVideo: ->
    @asset() instanceof App.Models.Video


  assetId: ->
    @asset()?.get('id')


  assetUrl: ->
    @asset()?.get('url')


  assetFilename: ->
    @asset()?.get('name')


  _storybook: ->
    @collection.keyframe.scene.storybook


##
# A generic widget that has an associated image.
class App.Models.ImageWidget extends App.Models.Widget

  url: ->
    @image()?.get('url')


  filename: ->
    @image().get('name')


  image: ->
    @images().get(@get('image_id'))


  images: ->
    @collection.storybook.images


##
# A sprite widget that belongs to a scene.
#
# It can have a different position or scale in each of the keyframes of the scene.
# @see App.Models.SpriteOrientation
class App.Models.SpriteWidget extends App.Models.ImageWidget
  # attributes: image_id

  defaults:
    type: 'SpriteWidget'


  parse: (attributes={}) ->
    if attributes.position?
      @position = attributes.position
      delete attributes.position

    if attributes.scale?
      @scale = attributes.scale
      delete attributes.scale

    attributes


  getOrientationFor: (keyframe) ->
    keyframe.getOrientationFor(@)


  applyOrientationFrom: (keyframe) ->
    orientation = getOrientationFor(keyframe)
    @set
      scale:    orientation.scale
      position: orientation.position


# The association between a SpriteWidget and a Keyframe; it stores the position
# and scale of the SpriteWidget in that Keyframe.
class App.Models.SpriteOrientation extends Backbone.Model
  # attributes: keyframe_id sprite_widget_id position scale
  defaults:
    type: 'SpriteOrientation'


  spriteWidget: ->
    sceneWidgets = @collection.keyframe.scene.widgets
    spriteWidgetId = @get('sprite_widget_id')
    sceneWidgets.find (widget) => widget.id == spriteWidgetId


##
# A button that has two associated images: one for its default state,
# and one for its tapped/clicked state
#
# It has a name, which shows the purpose of the button.
#
# It is added automatically to the main menu scene. It cannot be added from
# the UI.
#
class App.Models.ButtonWidget extends App.Models.ImageWidget
  # attributes: name selected_image_id position scale disabled

  defaults:
    type: 'ButtonWidget'


  filename: ->
    if @get('image_id')?
      super
    else
      @_defaultFilename()


  image: ->
    super || @defaultImage()


  defaultImage: ->
    @_defaultImage ||= new App.Models.Image(
      url:           @_defaultImageUrl()
      thumbnail_url: @_defaultImageUrl()
      name:          @_defaultFilename()
    )


  url: ->
    url = super
    url || @_defaultImageUrl()


  selectedImage: ->
    @images().get(@get('selected_image_id')) || @defaultSelectedImage()


  defaultSelectedImage: ->
    @_defaultSelectedImage ||= new App.Models.Image(
      url:           @_defaultSelectedImageUrl()
      thumbnail_url: @_defaultSelectedImageUrl()
      name:          @_defaultSelectedFilename()
    )


  selectedUrl: ->
    @selectedImage()?.get('url') || @url()


  displayName: ->
    @_displayName ||= App.Lib.StringHelper.capitalize(@get('name').replace(/_/g, ' '))


  _defaultImageUrl: ->
    '/assets/sprites/' + @_defaultFilename()


  _defaultFilename: ->
    @get('name') + '.png'


  _defaultSelectedImageUrl: ->
    '/assets/sprites/' + @_defaultSelectedFilename()


  _defaultSelectedFilename: ->
    @get('name') + '-over.png'

##
# A text object which is displayed on the canvas.
#
# It has a string option, which is the string to be shown when displayed
#
# Text widgets belong to keyframe
#
class App.Models.TextWidget extends App.Models.Widget
 # attributes: string, font, size

  defaults: ->
    type:    'TextWidget'
    string:  'Double click to edit or drag to move'
    z_order: 6000
    position: @defaultPosition()
    font_size: 25
    font_color: { 'r': 0, 'g': 0, 'b': 0 }


  initialize: ->
    super
    try
      @set(font_id: @storybook().defaultFont().get('id')) unless @get('font_id')
    catch error


  # Used to put filename of the font being used for a widget
  # in Storybook JSON.
  fontFileName: ->
    return 'arial.ttf' if (font = @font()).get('url') == 'Arial.ttf'
    font.get('url')


  font: ->
    @storybook().fonts.get(@get('font_id'))


  storybook: ->
    @collection?.keyframe.scene.storybook


  wordCount: ->
    App.Lib.StringHelper.wordCount @get('string')


##
# A collection of widgets.
# Relations:
# * keyframe - should be set if this collection belongs to a Keyframe
# * scene - should be set if this collection belongs to a Scene
class App.Collections.Widgets extends Backbone.Collection

  model: (attrs, options) ->
    new App.Models[attrs.type](attrs, $.extend({collection: @, parse: true}, options))


  remove: (widget) ->
    super unless widget instanceof App.Models.ButtonWidget


  imageRemoved: (image) ->
    @each (widget) =>
      if widget instanceof App.Models.SpriteWidget
        @remove widget if widget.get('image_id') == image.id
      if widget instanceof App.Models.ButtonWidget
        widget.set(image_id: null) if widget.get('image_id') == image.id
        widget.set(selected_image_id: null) if widget.get('selected_image_id') == image.id


  soundRemoved: (sound) ->
    @each (widget) =>
      if widget instanceof App.Models.HotspotWidget
        @remove widget if widget.get('sound_id')?.toString() is sound.get('id').toString()


  videoRemoved: (video) ->
    @each (widget) =>
      if widget instanceof App.Models.HotspotWidget
        @remove widget if widget.get('video_id')?.toString() is video.get('id').toString()


  fontRemoved: (font) ->
    @each (widget) =>
      if widget instanceof App.Models.TextWidget
        default_font_id = @keyframe.scene.storybook.defaultFont().id
        if widget.get('font_id').toString() is font.get('id').toString()
          if default_font_id?
            widget.set(font_id: default_font_id)
          else
            @remove widget


  byClass: (klass) ->
    @filter (w) -> w instanceof klass


  setMinZOrder: (sprite) ->
    peers = if sprite instanceof App.Models.SpriteWidget
      @byClass(App.Models.SpriteWidget)
    else if sprite instanceof App.Models.ButtonWidget
      @byClass(App.Models.ButtonWidget)
    min = _.min _.map(peers, (widget) -> widget.get('z_order'))
    unless min == sprite.get('z_order')
      # increase all by 1
      _.each peers, (widget) ->
        widget.set 'z_order', widget.get('z_order') + 1
      # set min to sprite
      sprite.set 'z_order', min


  setMaxZOrder: (sprite) ->
    peers = if sprite instanceof App.Models.SpriteWidget
      @byClass(App.Models.SpriteWidget)
    else if sprite instanceof App.Models.ButtonWidget
      @byClass(App.Models.ButtonWidget)
    max = _.max _.map(peers, (widget) -> widget.get('z_order'))
    unless max == sprite.get('z_order')
      # decrease all by 1
      _.each peers, (widget) ->
        widget.set 'z_order', widget.get('z_order') - 1
      # set max to sprite
      sprite.set 'z_order', max


  @containers:
    'SpriteWidget':  'scene'
    'TextWidget':    'keyframe'
    'HotspotWidget': 'keyframe'


##
# The collection of widgets that are present for the current keyframe.
# It listens for changes in the current keyframe and updates its contents
# to match what widgets exist for that keyframe, in an efficient manner.
class App.Collections.CurrentWidgets extends App.Collections.Widgets

  initialize: ->
    @currentKeyframe = null


  comparator: (widget) ->
    if widget instanceof App.Models.ImageWidget
      return widget.get('z_order')
    else if widget instanceof App.Models.HotspotWidget
      return widget.get('z_order') - 1/widget.id
    else if widget instanceof App.Models.TextWidget
      return widget.get('z_order')


  changeKeyframe: (keyframe) ->
    @updateStorybookWidgets(keyframe)
    @updateSceneWidgets(keyframe)
    @updateKeyframeWidgets(keyframe)

    @_removeListeners(@currentKeyframe)
    @currentKeyframe = keyframe
    @_addListeners(@currentKeyframe)


  updateStorybookWidgets: (keyframe) ->
    return unless @currentKeyframe?.scene != keyframe?.scene

    if @currentKeyframe?.scene.isMainMenu()
      widgets = @currentKeyframe.scene.storybook.widgets
      @add(widgets.models) if widgets?

    if keyframe?.scene.isMainMenu()
      widgets = keyframe.scene.storybook.widgets
      @remove(widgets.models) if widgets?


  updateSceneWidgets: (keyframe) ->
    if @currentKeyframe?
      if @currentKeyframe.scene != keyframe?.scene
        widgets = @currentKeyframe.scene.widgets
        @remove(widgets.models) if widgets?

    widgets = keyframe?.scene.widgets
    @add(widgets.models) if widgets?


  updateKeyframeWidgets: (keyframe) ->
    widgets = @currentKeyframe?.widgets
    @remove(widgets.models) if widgets?

    widgets = keyframe?.widgets
    @add(widgets.models) if widgets?


  _addListeners: (keyframe) ->
    return unless keyframe?

    keyframe.widgets.on       'add',    @_addWidget,    @
    keyframe.widgets.on       'remove', @_removeWidget, @
    keyframe.scene.widgets.on 'add',    @_addWidget,    @
    keyframe.scene.widgets.on 'remove', @_removeWidget, @


  _removeListeners: (keyframe) ->
    return unless keyframe?

    keyframe.widgets.off       'add',   @_addWidget,    @
    keyframe.scene.widgets.off 'add',   @_addWidget,    @
    # not sure why these are not needed, but tests show that they aren't
    # @dira 2013-03-27
    # keyframe.widgets.off       'remove', @remove, @
    # keyframe.scene.widgets.off 'remove', @remove, @


  _addWidget: (widget) ->
    @add(widget)


  _removeWidget: (widget) ->
    @remove(widget)
