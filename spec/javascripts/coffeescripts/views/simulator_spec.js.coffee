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
    beforeEach ->
      @nrSwipes = 19

      @storybook.mainMenuLayer.readItMyself()

    it 'should work for pressing "next" until the end', ->
      @storybook.showNextPage() for swipe in [1..@nrSwipes]
      expect(1).toEqual(1)

    describe 'on the last page', ->
      beforeEach ->
        @storybook.showNextPage() for swipe in [1..@nrSwipes]

      it 'has the right page number', ->
        expect(@storybook.currentPageNumber).toEqual 9

      it 'has the right paragraph number', ->
        expect(@storybook.pageLayer.currentParagraphNumber).toEqual 1


      it 'errors if next is pressed again', ->
        expect((-> @storybook.showNextPage()).bind(@)).toThrow()

      # WIP - not working yet because the test does not wait for cc
      # to actually show things. So `pageLayer.onEnter` is executed at
      # the end of the suite's execution. Which means `@showParagraph`
      # (and correspondingly, setting the paragraph number to 0 when going
      # backwards) is not waited for, and the paragraph numbers go negative.
      # it 'allows going back to the first page', ->
        # @storybook.showPreviousPage() for swipe in [1..@nrSwipes]
        # expect(1).toEqual(1)

      # describe 'on the first page', ->
        # beforeEach ->
          # @storybook.showPreviousPage() for swipe in [1..@nrSwipes]

        # it 'has the right page number', ->
          # expect(@storybook.currentPageNumber).toEqual 1

        # it 'has the right paragraph number', ->
          # expect(@storybook.pageLayer.currentParagraphNumber).toEqual 0
