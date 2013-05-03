describe "App.Models.ButtonWidget", ->

  describe 'initialization', ->
    it 'has the right defaults', ->
      @widget = new App.Models.ButtonWidget
      expect(@widget.get('type')).toEqual 'ButtonWidget'

    describe 'filename', ->
      it 'sets the filename based on the name, if not present', ->
        @widget = new App.Models.ButtonWidget(name: 'kind')
        expect(@widget.get('filename')).toEqual 'kind.png'

      it 'keeps the provided filename', ->
        @widget = new App.Models.ButtonWidget(filename: 'file.png')
        expect(@widget.get('filename')).toEqual 'file.png'

    describe 'url', ->
      it 'sets the url based on the name, if url and filename are not present', ->
        @widget = new App.Models.ButtonWidget(name: 'kind')
        expect(@widget.get('url')).toEqual '/assets/sprites/kind.png'

      it 'sets the url based on the filename, if url is not present but filename is', ->
        @widget = new App.Models.ButtonWidget(filename: 'file.png')
        expect(@widget.get('url')).toEqual '/assets/sprites/file.png'

      it 'keeps the provided url', ->
        @widget = new App.Models.ButtonWidget(url: 'url')
        expect(@widget.get('url')).toEqual 'url'

