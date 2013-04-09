if Rails.env.test? || Rails.env.development?
  Rails.application.config.assets.paths << Rails.root.join("spec", "javascripts", "assets").to_s
end
