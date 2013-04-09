describe "Simulator", ->

  beforeEach ->
    loadFixtures('simulator')

    # The json from: https://github.com/curiousminds/interapptive-web/blob/331aa45a0a06fd669c147cacc87e24b8fe163d69/app/views/assets/_simulator.html.haml
    json = getJSONFixture('storybook_json/ipad.json')
    expect(json).toBeDefined()

    Sim.run()
    cc.AppController.shareAppController().didFinishLaunchingWithOptions()
    @storybook = new Sim.Storybook(json)

  describe 'interaction', ->

    it 'should work for pressing "next" until the end', ->
      @storybook.mainMenuLayer.readItMyself()
      @storybook.showNextPage() for swipe in [1..5000]
      expect(@storybook.currentPageNumber).toEqual 2
