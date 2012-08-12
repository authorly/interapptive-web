module JsonApiHelpers
  require 'rack/test'
  include Rack::Test::Methods

  def app
    Rails.application
  end
end