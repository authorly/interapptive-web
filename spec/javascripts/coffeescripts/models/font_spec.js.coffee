describe "App.Models.Font", ->
  beforeEach ->
    @font = new App.Models.Font(name: "Some Font Name")

  describe '#toString', ->
    it 'should give font name', ->
      expect(@font.toString()).toEqual(@font.get('name'))
