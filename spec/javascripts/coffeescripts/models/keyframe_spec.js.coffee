describe "App.Models.Keyframe", ->

  beforeEach ->
    @server = sinon.fakeServer.create()
    @storybook = new App.Models.Storybook(id: 1)

    @scene = new App.Models.Scene({
      id: 1,
      image_id: 1,
      sound_id: 2,
      preview_image_id: 3,
      position: 1,
      content_highlight_times: [1, 2, 3, 4],
    },
    {
      collection: @storybook.scenes
    })


    @keyframe = new App.Models.Keyframe scene: @scene


  afterEach ->
    @server.restore()

  it 'knows its text widgets', ->
    @keyframe.widgets.add [type: 'TextWidget']
    @keyframe.widgets.add [type: 'SpriteWidget']

    expect(@keyframe.textWidgets().length).toEqual(1)
