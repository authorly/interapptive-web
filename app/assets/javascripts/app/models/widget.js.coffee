# `z_order` range:
# [1..4000) for sprites
# [4000-5000) buttons
# [5000..6000) hotspots
# [6000...) texts
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
    glitter: true


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


  assetType: ->
    if @hasSound()
      'sound'
    else if @hasVideo()
      'video'


  assetUrl: ->
    if @hasSound()
      @asset().get('url')
    else if @hasVideo()
      asset = @asset()
      asset.get('mp4url') || asset.get('url')


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


  asPreviousKeyframe: (keyframe) ->
    App.trackUserAction 'Applied "as in previous scene frame"'

    previous = keyframe.previous()
    return unless previous?

    oldOrientation = @getOrientationFor(keyframe)
    newOrientation = @getOrientationFor(previous)
    oldOrientation.set
      scale:    newOrientation.get('scale')
      position: _.extend {}, newOrientation.get('position')


  asNextKeyframe: (keyframe) ->
    App.trackUserAction 'Applied "as in next scene frame"'

    next = keyframe.next()
    return unless next?

    oldOrientation = @getOrientationFor(keyframe)
    newOrientation = @getOrientationFor(next)
    oldOrientation.set
      scale:    newOrientation.get('scale')
      position: _.extend {}, newOrientation.get('position')


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
    z_order: 4000


  initialize: ->
    super
    @listenTo @, 'change:image_id', @resetScale


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


  useDefaultImage: ->
    @set
      image_id: @defaultImage().id


  resetScale: ->
    @set scale: 1


  defaultSelectedImage: ->
    @_defaultSelectedImage ||= new App.Models.Image(
      url:           @_defaultSelectedImageUrl()
      thumbnail_url: @_defaultSelectedImageUrl()
      name:          @_defaultSelectedFilename()
    )


  selectedUrl: ->
    @selectedImage()?.get('url') || @url()


  displayName: ->
    @_displayName ||= switch name=@get('name')
      when 'home' then 'Home button'
      else
        App.Lib.StringHelper.capitalize(@get('name').replace(/_/g, ' '))


  isHomeButton: ->
    @get('name') == 'home'


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
 # attributes: string, font_color, font_size, align ['left', 'center', 'right']

  defaults: ->
    type:    'TextWidget'
    position: @defaultPosition()
    z_order: 6000
    string:  'Click to edit or drag to move'
    font_size: 34
    font_color: { 'r': 0, 'g': 0, 'b': 0 }
    align: 'left'


  initialize: ->
    super
    try
      @set(font_id: @storybook().defaultFont().get('id')) unless @get('font_id')
    catch error


  # Used to put filename of the font being used for a widget
  # in Storybook JSON.
  fontFileName: ->
    font = @font()

    if font.isSystem()
      # Mobile software does not pick up Arial font if it's referenced as Arial.ttf in JSON.
      # This issue is way to convoluted to fix in the mobile software.
      return 'arialother.ttf' if font.get('file_name') == 'Arial.ttf'

      # Mobile software can not handle spaces in font file names in default fonts. For user
      # uploaded fonts. The fonts are named such that those dont have spaces in them after
      # downloading.
      font.get('file_name').replace(/\ /g, '')
    else
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
    @remove _.select @byClass(App.Models.SpriteWidget), (widget) ->
      widget.get('image_id') == image.id

    _.each @byClass(App.Models.ButtonWidget), (widget) ->
      widget.set(image_id: null) if widget.get('image_id') == image.id
      widget.set(selected_image_id: null) if widget.get('selected_image_id') == image.id


  soundRemoved: (sound) ->
    @remove _.select @byClass(App.Models.HotspotWidget), (widget) ->
      widget.get('sound_id')?.toString() is sound.get('id').toString()


  videoRemoved: (video) ->
    @remove _.select @byClass(App.Models.HotspotWidget), (widget) ->
      widget.get('video_id')?.toString() is video.get('id').toString()


  fontRemoved: (font) ->
    defaultFont = @keyframe.scene.storybook.defaultFont()
    fonts = _.select @byClass(App.Models.TextWidget), (widget) ->
      widget.get('font_id').toString() is font.id.toString()
    if defaultFont?
      _.each fonts, (widget) -> widget.set(font_id: defaultFont.id)
    else
      @remove fonts


  byClass: (klass) ->
    @filter (w) -> w instanceof klass


  setMinZOrder: (sprite) ->
    peers = if sprite instanceof App.Models.SpriteWidget
      @byClass(App.Models.SpriteWidget)
    else if sprite instanceof App.Models.ButtonWidget
      @byClass(App.Models.ButtonWidget)
    min = _.min _.map(peers, (widget) -> widget.get('z_order'))
    zOrder = sprite.get('z_order')
    unless min == zOrder
      _.each peers, (widget) ->
        if (currentZOrder = widget.get('z_order')) < zOrder
          widget.set 'z_order', currentZOrder + 1
      # set min to sprite
      sprite.set 'z_order', min


  setMaxZOrder: (sprite) ->
    peers = if sprite instanceof App.Models.SpriteWidget
      @byClass(App.Models.SpriteWidget)
    else if sprite instanceof App.Models.ButtonWidget
      @byClass(App.Models.ButtonWidget)
    max = _.max _.map(peers, (widget) -> widget.get('z_order'))
    zOrder = sprite.get('z_order')
    unless max == zOrder
      _.each peers, (widget) ->
        if (currentZOrder = widget.get('z_order')) > zOrder
          widget.set 'z_order', currentZOrder - 1
      # set max to sprite
      sprite.set 'z_order', max


  @validZOrder: (order) ->
    return true if order.length == 0

    z_order_array = _.map order, ([k, v]) -> k
    firstButtonIndex = _.max(z_order_array) + 1
    lastSpriteIndex  = _.min(z_order_array) - 1

    for [index, widget] in order
      if widget instanceof App.Models.SpriteWidget
        lastSpriteIndex  = index if index > lastSpriteIndex
      if widget instanceof App.Models.ButtonWidget
        firstButtonIndex = index if index < firstButtonIndex

    firstButtonIndex > lastSpriteIndex


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
    return if @currentKeyframe?.scene == keyframe?.scene

    widgets = keyframe?.scene.storybook.widgets
    return unless widgets?

    if keyframe?.scene.isMainMenu()
      @remove(widgets.models)
    else
      @add(widgets.models)


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
