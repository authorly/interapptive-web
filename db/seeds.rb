# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

ActionDefinition.delete_all
action_definitions = YAML::load(ERB.new(IO.read(File.join(Rails.root, 'db', 'fixtures', 'action_definitions.yml'))).result)
action_definitions.each do |k, v|
  ActionDefinition.create(v)
end

AttributeDefinition.delete_all
attribute_definitions = YAML::load(ERB.new(IO.read(File.join(Rails.root, 'db', 'fixtures', 'attribute_definitions.yml'))).result)
attribute_definitions.each do |k, v|
  AttributeDefinition.create(v)
end

Font.where(:asset_type => 'system').delete_all
system_fonts = YAML::load(ERB.new(IO.read(File.join(Rails.root, 'db', 'fixtures', 'system_fonts.yml'))).result)
system_fonts.each do |k, v|
  f = Font.create(v.merge(:meta_info => { :font_name => k }))
end
