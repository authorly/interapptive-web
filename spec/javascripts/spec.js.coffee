#= require jquery
#= require underscore
#= require backbone
#= require backbone-deepmodel

#= require_tree ./
#= require_tree ../../vendor/assets/javascripts
#= require_tree ../../app/assets/javascripts
#
App.init()

beforeEach ->
  matchers =
    toContainWidgets: (expected) ->
      toS = (e) -> "#{e.get('type')}(cid=#{e.cid})"

      @message = -> "Expected #{@actual.map toS} to equal #{_.map expected, toS}"

      _.pluck(@actual.models, 'cid').sort().join(',') == _.map(expected, (e) -> e.cid).sort().join(',')

  @addMatchers matchers

afterEach ->
  # clear all timeouts - a hack based on the assumption that timeouts are given
  # consecutive ids
  distantTimeout = setTimeout('alert("x");',100000)
  clearTimeout(i) for i in [0..distantTimeout]

