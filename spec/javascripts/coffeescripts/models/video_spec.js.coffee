describe "App.Models.Video", ->
  beforeEach ->
    storybook = new App.Models.Storybook(id: 1)
    scene = new App.Models.Scene({}, { collection: storybook.scenes })

    App.currentSelection.set(storybook: storybook)
    App.currentSelection.set(scene: scene)
    @video = new App.Models.Video(name: "Some Video Name")

  it 'should have url based on current scene and storybook', ->
    expect(@video.url()).toEqual('/storybooks/' + App.currentSelection.get('storybook').get("id") + '/scenes/' + App.currentSelection.get('scene').get("id") + '/videos.json')

  describe '#toString', ->
    it 'should give video name', ->
      expect(@video.toString()).toEqual(@video.get('name'))

  describe '#toSelectOption', ->
    it 'should give object with name and id', ->
      expect(@video.toSelectOption()).toEqual({ val: @video.get('id'), label: @video.get('name') })
