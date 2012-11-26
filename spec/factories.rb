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

Factory.define :sound, class: Asset do |f|
  f.type 'Sound'
  f.sound 'audio-file.mp3'
end


Factory.define :image do |f|
  f.type 'Image'
  f.image 'image.jpg'
end

Factory.define :video, class: Asset do |f|
  f.type 'Video'
  f.video 'movie.mp4'
end

Factory.define :font, class: Asset do |f|
  f.type 'Font'
  f.video 'custom-font.ttf'
end

Factory.define :scene do |f|
  f.preview_image_id Factory.create(:image)
  f.sound_id Factory.create(:sound).id
  f.storybook Factory.create(:storybook)
end

Factory.define :keyframe do |f|
  f.scene_id Factory.create(:scene)
  f.preview_image_id Factory.create(:image)
end

Factory.define :animation_keyframe, class: Keyframe do |f|
  f.scene_id Factory.create(:scene)
  f.preview_image_id Factory.create(:image)
  f.is_animation true
  f.position nil
end

Factory.define :actions do |f|
  f.scene Factory.create(:scene)
end

Factory.define :settings do |f|
  f.type "font.ttf"
  f.scene_id Factory.create(:scene)
  f.storybook_id Factory.create(:storybook)
  font = Factory.create(:font)
  f.font_id font
  f.font_size font
end

Factory.define :storybook_settings do |f|
  f.type "font.ttf"
  f.scene_id Factory.create(:scene)
  f.storybook_id Factory.create(:storybook)
  font = Factory.create(:font)
  f.font_id font
  f.font_size font
end

Factory.define :keyframe_text do |f|
  f.keyframe_id 1 # hack alert
  f.content "This is some content"
  f.content_highlight_times "Don't know what this is"
  f.x_coord 200
  f.y_coord 200
  f.face "Arial"
  f.size 14
  f.color "FFFFFF"
end
