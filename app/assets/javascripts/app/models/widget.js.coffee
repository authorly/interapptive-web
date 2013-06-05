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


  sounds: ->
    @collection.scene.storybook.sounds


  videos: ->
    @collection.scene.storybook.videos


  asset: ->
    if @get('sound_id')
      @sounds().get(@get('sound_id'))
    else if @get('video_id')
      @videos().get(@get('video_id'))
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
  # attributes: name selected_image_id

  defaults:
    type: 'ButtonWidget'


  filename: ->
    if @get('image_id')?
      super
    else
      @_defaultFilename()


  image: ->
    super || new App.Models.Image(url: @_defaultImageUrl())


  url: ->
    url = super
    url || @_defaultImageUrl()


  selectedImage: ->
    @images().get(@get('selected_image_id')) ||
      new App.Models.Image(url: @_defaultSelectedImageUrl())


  selectedUrl: ->
    @selectedImage()?.get('url') || @url()


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
    string:  'Enter some text...'
    z_order: 6000
    position: @defaultPosition()
    font_id: null
    font_face: 'Arial'
    font_size: 25
    font_color: { 'r': 255, 'g': 0, 'b': 0 }


  # Used to retrieve font face name for the widget that should
  # be put in CSS/HTML for correct rendering.
  fontName: ->
    if @get('font_id')
      font = @collection.keyframe.scene.storybook.fonts.get(@get('font_id'))
      return font.get('name')
    else
      return @get('font_face')


  # Used to set correct font value in the font select dropdown
  fontValue: ->
    if @get('font_id')
      font = @collection.keyframe.scene.storybook.fonts.get(@get('font_id'))
      return font.get('id')
    else
      return @get('font_face')


  # Used to put filename of the font being used for a widget
  # in Storybook JSON.
  fontFileName: ->
    if @get('font_id')
      font = @collection.keyframe.scene.storybook.fonts.get(@get('font_id'))
      return font.get('url')
    else
      # Following assumes that all system fonts are TTF.
      return 'arial.ttf' if @get('font_face') == 'Arial'
      return @get('font_face').replace(/\ /g, '') + '.ttf'


##
# A collection of widgets.
# Relations:
# * keyframe - should be set if this collection belongs to a Keyframe
# * scene - should be set if this collection belongs to a Scene
class App.Collections.Widgets extends Backbone.Collection

  model: (attrs, options) ->
    new App.Models[attrs.type](attrs, $.extend({}, options, parse: true))


  remove: (widget) ->
    super unless widget instanceof App.Models.ButtonWidget


  imageRemoved: (image) ->
    @each (widget) =>
      if widget instanceof App.Models.SpriteWidget
        @remove widget if widget.get('image_id') == image.id
      if widget instanceof App.Models.ButtonWidget
        widget.set(image_id: null) if widget.get('image_id') == image.id
        widget.set(selected_image_id: null) if widget.get('selected_image_id') == image.id



  byClass: (klass) ->
    @filter (w) -> w instanceof klass


  isHomeButton: ->
    @get('name') == 'home'

  @containers:
    'HotspotWidget': 'scene'
    'SpriteWidget':  'scene'
    'TextWidget':    'keyframe'


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

    keyframe.widgets.on       'add',    @add,    @
    keyframe.widgets.on       'remove', @remove, @
    keyframe.scene.widgets.on 'add',    @add,    @
    keyframe.scene.widgets.on 'remove', @remove, @


  _removeListeners: (keyframe) ->
    return unless keyframe?

    keyframe.widgets.off       'add',    @add,    @
    keyframe.scene.widgets.off 'add',    @add,    @
    # not sure why these are not needed, but tests show that they aren't
    # @dira 2013-03-27
    # keyframe.widgets.off       'remove', @remove, @
    # keyframe.scene.widgets.off 'remove', @remove, @
