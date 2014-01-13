App.initStorybook()

# these perform in parallel
App.Builder.init()

id = Number document.location.pathname.replace('/storybooks/', '')
App.showStorybook(id)
