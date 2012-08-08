Factory.define :user do |f|
  f.email 'user%d@example.com'
  f.password f.password_confirmation('supersecret')
end

Factory.define :storybook do |f|
  f.title 'Test Title'
  f.author 'Charles Bukowski'
  f.description 'This book is for true champions'
  f.publisher 'Black Sparrow Press'
  f.price 20.00
  f.record_enabled 'true' # note sure about this attribute. kurt b
  f.android_or_ios 'android'
  f.tablet_or_phone 'tablet'
end


