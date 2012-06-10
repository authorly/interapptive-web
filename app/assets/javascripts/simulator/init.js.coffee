window.Sim = {}

window.runSimulator = ->
  cc.AppDelegate = Sim.AppDelegate
  cc.setup("simulator-canvas")

  preloader = cc.Loader.shareLoader()

  # Show loading screen when assets are preloading
  preloader.onloading = ->
      cc.LoaderScene.shareLoaderScene().draw()

  # Initialise when all assets have loaded
  preloader.onload = ->
      cc.AppController.shareAppController().didFinishLaunchingWithOptions()

  # Preload our assets
  preloader.preload([
      # FIXME Fonts not supported?
      #{type: 'font',  src: '/resources/PoeticaChanceryIII.ttf'},
      #{type: 'font',  src: '/resources/PopplPontifexBE-Regular.ttf'},
      {type: 'image', src: '/resources/autoplay-over.png'},
      {type: 'image', src: '/resources/autoplay.png'},
      {type: 'image', src: '/resources/background0000.jpg'},
      {type: 'image', src: '/resources/background0010.jpg'},
      {type: 'image', src: '/resources/background0020.jpg'},
      {type: 'image', src: '/resources/background0030.jpg'},
      {type: 'image', src: '/resources/background0040.jpg'},
      {type: 'image', src: '/resources/background0050.jpg'},
      {type: 'image', src: '/resources/background0060.jpg'},
      {type: 'image', src: '/resources/background0070.jpg'},
      {type: 'image', src: '/resources/background0080.jpg'},
      {type: 'image', src: '/resources/background0090.jpg'},
      {type: 'image', src: '/resources/background0100.jpg'},
      {type: 'image', src: '/resources/home-button-over.png'},
      {type: 'image', src: '/resources/home-button.png'},
      {type: 'image', src: '/resources/r1.png'},
      {type: 'image', src: '/resources/r2.png'},
      {type: 'image', src: '/resources/read-it-myself-over.png'},
      {type: 'image', src: '/resources/read-it-myself.png'},
      {type: 'image', src: '/resources/read-to-me-over.png'},
      {type: 'image', src: '/resources/read-to-me.png'},
      {type: 'image', src: '/resources/stranger-in-the-woods-logo.png'},
      {type: 'image', src: '/resources/touchable-node-particle-glitter.png'}
  ])

