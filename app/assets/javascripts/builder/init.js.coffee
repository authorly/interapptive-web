cc.Log = cc.LOG = console.log.bind(console)

window.initBuilder = ->
  cc.setup "builder-canvas"

  # Disable I-beam
  $(cc.canvas).on('mousedown', (e) ->
    e.preventDefault()
    false
  )

  cc.Loader.shareLoader().onloading = ->
    console.log "LOADING...."

  cc.Loader.shareLoader().onload = ->
    cc.AppController.shareAppController().didFinishLaunchingWithOptions()

  cc.Loader.shareLoader().preload []
