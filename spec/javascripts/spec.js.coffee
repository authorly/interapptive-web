# FOUNDATION
#= require jquery
#= require underscore
#= require backbone
#= require backbone-deepmodel

# VENDOR
#= require ../../vendor/assets/javascripts/bootstrap
#= require ../../vendor/assets/javascripts/backbone-forms

#= require ../../vendor/assets/javascripts/jquery-file-upload/jquery.iframe-transport
#= require ../../vendor/assets/javascripts/jquery-file-upload/jquery.ui.widget
#= require ../../vendor/assets/javascripts/jquery-file-upload/jquery.fileupload
#= require ../../vendor/assets/javascripts/jquery-file-upload/jquery.fileupload-process
#= require ../../vendor/assets/javascripts/jquery-file-upload/jquery.fileupload-validate
#= require ../../vendor/assets/javascripts/jquery-file-upload/jquery.fileupload-ui
#= require ../../vendor/assets/javascripts/jquery-file-upload/jquery.fileupload-jquery-ui

#= require_tree ../../vendor/assets/javascripts

# APP
#= require_tree ../../app/assets/javascripts

# TESTS
#= require_tree .

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

