describe "App.Models.Sound", ->
  beforeEach ->
    @sound = new App.Models.Sound(name: "Some Sound Name")


  describe '#toString', ->
    it 'should give sound name', ->
      expect(@sound.toString()).toEqual(@sound.get('name'))
