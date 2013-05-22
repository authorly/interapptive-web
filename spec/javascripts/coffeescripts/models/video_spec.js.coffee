describe "App.Models.Video", ->
  beforeEach ->
    @video = new App.Models.Video(name: "Some Video Name")


  describe '#toString', ->
    it 'should give video name', ->
      expect(@video.toString()).toEqual(@video.get('name'))
