(->
  id = Number document.location.pathname.replace('/storybooks/', '')
  App.initStorybook()

  # these perform in parallel
  App.Builder.init()
  App.showStorybook(id)
)()
