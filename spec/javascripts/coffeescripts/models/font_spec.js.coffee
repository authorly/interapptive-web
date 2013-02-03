describe "App.Models.Font", ->
  beforeEach ->
    storybook = new App.Models.Storybook(id: 1)
    @font = new App.Models.Font(name: "Some Font Name")

  # it 'should have url based on current scene and storybook', ->
    # expect(@font.url()).toEqual('/storybooks/' + App.currentSelection.get('storybook').get("id") + '/scenes/' + App.currentSelection.get('scene').get("id") + '/fonts.json')

  describe '#toString', ->
    it 'should give font name', ->
      expect(@font.toString()).toEqual(@font.get('name'))
