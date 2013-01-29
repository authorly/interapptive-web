describe "App.Models.Sound", ->
  beforeEach ->
    storybook = new App.Models.Storybook(id: 1)
    scene = new App.Models.Scene({}, { collection: storybook.scenes })

    App.currentSelection.set(storybook: storybook)
    App.currentSelection.set(scene: scene)
    @sound = new App.Models.Sound(name: "Some Sound Name")

  it 'should have url based on current scene and storybook', ->
    expect(@sound.url()).toEqual('/storybooks/' + App.currentSelection.get('storybook').get("id") + '/scenes/' + App.currentSelection.get('scene').get("id") + '/sounds.json')

  describe '#toString', ->
    it 'should give sound name', ->
      expect(@sound.toString()).toEqual(@sound.get('name'))

  describe '#toSelectOption', ->
    it 'should give object with name and id', ->
      expect(@sound.toSelectOption()).toEqual({ val: @sound.get('id'), label: @sound.get('name') })
