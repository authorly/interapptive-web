describe "App.Views.VoiceoverIndex", ->

  beforeEach ->
    @storybook = new App.Models.Storybook(id: 1)

    @scene = new App.Models.Scene({
      id: 1,
      image_id: 1,
      sound_id: 2,
      preview_image_id: 3,
      page_number: 1
    },
    {
      collection: @storybook.scenes
    })

    @keyframe = new App.Models.Keyframe({
      id: 100,
      scene: @scene
      content_highlight_times: [1, 2, 3]
      widgets: [
        {
          type: 'TextWidget'
          string: 'For those who'
        }
      ]
    })

    @voiceover_index = new App.Views.VoiceoverIndex(@keyframe)
    sinon.spy App.vent, 'trigger'
    @server = sinon.fakeServer.create()

  afterEach ->
    App.vent.trigger.restore()
    @server.restore()

  describe "Instantiation", ->
    it "should have a keyframe property", ->
      expect(@voiceover_index.keyframe).toBeDefined()

  describe "Rendering", ->
    it "should render its text widgets ", ->
      expect($.trim($(@voiceover_index.render().el).find('.word').first().text())).toBe('For')

  #
  # TODO: Need to setup a fake 'file' to act as the voiceover.
  # That way we can test functionality that is dependent
  # on whether or not the audio exists (which is quite a bite)
  #
  # Also, would like to figure out how to successfully trigger the
  # `success` callback inside the `acceptAligntment` function
  #

  # describe '#acceptAlignment', ->
  #   it 'triggers hide event on App.vent', ->
  #     event =
  #       type: 'click',
  #       preventDefault: ->
  #     @voiceover_index.acceptAlignment(event)
  #     # Should
  #     #expect(App.vent.trigger).toHaveBeenCalledWith('hide:modal')

