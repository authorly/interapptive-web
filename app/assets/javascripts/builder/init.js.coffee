cc.Log = cc.LOG = console.log.bind(console)

window.initBuilder = ->
  cc.setup "builder-canvas"

  cc.Loader.shareLoader().onloading = ->
    console.log "LOADING...."

  cc.Loader.shareLoader().onload = ->
    cc.AppController.shareAppController().didFinishLaunchingWithOptions()

  cc.Loader.shareLoader().preload []