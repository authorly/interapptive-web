Airbrake.configure do |config|
  if Rails.env == 'production'
    config.api_key = '7e87edd4d0698fdaad610b5d7cc4d28d'
  else
    config.api_key = '42970e138183dde448948c66e45b4f83'
  end
end
