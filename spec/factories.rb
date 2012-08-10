require 'ffaker'
require 'forgery'

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

# controllers
# Factory.define do 
#   factory :storybook do 
#     title { FFaker::Lorem.sentence }
#     author { "#{FFaker::Name.first_name} #{FFaker::Name.last_name}" }
#     description { FFaker::Lorem.paragraph }
#     publisher { FFaker::Lorem.sentence }
#     price { Forgery(:money) }
#     record_enabled { [true, false].sample } 
#     android_or_ios { ["android", "ios"].sample }
#     tablet_or_phone { ["table", "phone"].sample }
#   end
# end  


