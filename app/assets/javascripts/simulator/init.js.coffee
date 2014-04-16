# preload fonts
fonts = JSON.parse(window.frameElement.getAttribute('data-fonts'))
fontCache = new App.Views.FontCache
$('head').append(fontCache.render().el)
fontCache.setCollection(new Backbone.Collection(fonts))

# start the simulator
json = JSON.parse(window.frameElement.getAttribute('data-json'))
Sim.run(json)
