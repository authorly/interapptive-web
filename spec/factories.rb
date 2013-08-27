require 'ffaker'
require 'forgery'

Factory.define :user do |f|
  f.username 'user%d'
  f.email    'user%d@example.com'
  f.password f.password_confirmation('supersecret')
  f.allowed_storybooks_count 100
end

Factory.define :storybook do |f|
  f.title 'Test Title'
  f.author 'Charles Bukowski'
  f.description 'This book is for true champions'
  f.price 20.00
  f.user Factory(:user)
end

Factory.define :sound do |f|
  f.type 'Sound'
  f.sound 'audio-file.mp3'
end


Factory.define :image do |f|
  f.type 'Image'
  f.image 'image.jpg'
end

Factory.define :video do |f|
  f.type 'Video'
  f.video 'movie.mp4'
end

Factory.define :font do |f|
  f.type 'Font'
  f.video 'custom-font.ttf'
end

Factory.define :scene do |f|
  f.preview_image Factory(:image)
  f.sound Factory(:sound)
  f.storybook Factory(:storybook)
end

Factory.define :main_menu_scene, class: Scene do |f|
  f.preview_image Factory(:image)
  f.sound Factory(:sound)
  f.storybook { Factory(:storybook).tap{|s| s.scenes.destroy_all } }
  f.is_main_menu true
  f.position nil
end

Factory.define :keyframe do |f|
  f.scene Factory(:scene)
  f.preview_image Factory(:image)
end

Factory.define :animation_keyframe, class: Keyframe do |f|
  f.scene Factory(:scene)
  f.preview_image Factory(:image)
  f.is_animation true
  f.position nil
end

Factory.define :actions do |f|
  f.scene Factory(:scene)
end
