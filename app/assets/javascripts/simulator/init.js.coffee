window.Sim = {}

initSimulator = (json) ->
  Sim._initalized = true
  storybook = new Sim.Storybook(json)

  np = $('#sim-next-page')
  pp = $('#sim-prev-page')

  np.on('click', -> storybook.showNextPage())
  pp.on('click', -> storybook.showPreviousPage())


window.Sim.run = (json) ->
  cc.AppDelegate = Sim.AppDelegate
  cc.setup("simulator-canvas")

  if Sim._initalized
    initSimulator()
    return 

  preloader = cc.Loader.shareLoader()

  # Show loading screen when assets are preloading
  preloader.onloading = ->
      cc.LoaderScene.shareLoaderScene().draw()

  # Initialise when all assets have loaded
  preloader.onload = ->
      cc.AppController.shareAppController().didFinishLaunchingWithOptions()
      initSimulator(json)

  # Preload our assets
  preloader.preload([
    # FIXME need to dynamically preload our assets from the JSON
    {type: 'image', src: '/assets/simulator/logo.png'}
    {type: 'image', src: '/resources/home-button.png'}
    {type: 'image', src: '/resources/autoplay.png'}
    {type: 'image', src: '/resources/read-it-myself.png'}
    {type: 'image', src: '/resources/read-to-me.png'}

      # FIXME Fonts not supported?
      #{type: 'font',  src: '/resources/PoeticaChanceryIII.ttf'},
      #{type: 'font',  src: '/resources/PopplPontifexBE-Regular.ttf'},
      #{type: 'image', src: '/resources/autoplay-over.png'},
      #{type: 'image', src: '/resources/autoplay.png'},
      #{type: 'image', src: '/resources/home-button-over.png'},
      #{type: 'image', src: '/resources/home-button.png'},
      #{type: 'image', src: '/resources/r1.png'},
      #{type: 'image', src: '/resources/r2.png'},
      #{type: 'image', src: '/resources/read-it-myself-over.png'},
      #{type: 'image', src: '/resources/read-it-myself.png'},
      #{type: 'image', src: '/resources/read-to-me-over.png'},
      #{type: 'image', src: '/resources/read-to-me.png'},
      #{type: 'image', src: '/resources/stranger-in-the-woods-logo.png'},
      #{type: 'image', src: '/resources/touchable-node-particle-glitter.png'}
  ])

