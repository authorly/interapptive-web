class App.Views.AssetFilter extends Backbone.View
  events:
    'click li': 'filterClicked'


  initialize: (options) ->
    @vent = options.vent


  setup: ->
    @filterClicked currentTarget: @$('.active')


  filterClicked: (event) ->
    target = @$(event.currentTarget)

    target.siblings().removeClass('active')
    target.addClass('active')

    @trigger 'filter', target.data('filter')
