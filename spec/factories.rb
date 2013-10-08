require 'ffaker'
require 'forgery'

Factory.define :user do |f|
  f.username 'user%d'
  f.email    'user%d@example.com'
  f.company  'Authorly'
  f.password f.password_confirmation('supersecret')
  f.allowed_storybooks_count 100
end

Factory.define :storybook do |f|
  f.title 'Storybook %d'
  f.author 'Charles Bukowski'
  f.user Factory(:user)
end

Factory.define :sound do |f|
  f.type 'Sound'
  f.sound 'audio-file.mp3'
end


Factory.define :image do |f|
  f.type 'Image'
  f.image { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'images', '500x300.png')) }
end

Factory.define :video do |f|
  f.type 'Video'
  f.video 'movie.mp4'
end

Factory.define :font do |f|
  f.type 'Font'
  f.video 'custom-font.ttf'
end

Factory.define :application_information do |f|
  f.storybook Factory(:storybook)
  f.large_icon Factory(:image)
  f.description 'This book is for true champions'
  f.keywords 'keyword1, keyword2'
  f.available_from 2.days.from_now
  f.price_tier 'tier_1'
  f.content_description({
      'fantasy_violence' =>         'none',
      'realistic_violence' =>       'mild',
      'sexual_content' =>           'intense',
      'profanity' =>                'mild',
      'drugs' =>                    'none',
      'mature' =>                   'intense',
      'gambling' =>                 'none',
      'horror' =>                   'mild',
      'prolonged_violence' =>       'none',
      'graphical_sexual_content' => 'none',
  })
  f.retina_3_5_screenshot_ids  { [Factory(:image).id, Factory(:image).id] }
  f.retina_4_0_screenshot_ids  { [Factory(:image).id, Factory(:image).id] }
  f.retina_ipad_screenshot_ids { [Factory(:image).id, Factory(:image).id] }
end

Factory.define :scene do |f|
  f.sound Factory(:sound)
  f.storybook Factory(:storybook)
end

Factory.define :main_menu_scene, class: Scene do |f|
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
