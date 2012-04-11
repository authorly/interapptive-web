Factory.define :user do |f|
  f.email 'user%d@example.com'
  f.password f.password_confirmation('supersecret')
end
