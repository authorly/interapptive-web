# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

ActionDefinition.delete_all
AttributeDefinition.delete_all

action_definitions = YAML::load(ERB.new(IO.read(File.join(Rails.root, 'db', 'fixtures', 'action_definitions.yml'))).result)

action_definitions.each do |k, v|
  ActionDefinition.create(v)
end

attribute_definitions = YAML::load(ERB.new(IO.read(File.join(Rails.root, 'db', 'fixtures', 'attribute_definitions.yml'))).result)

attribute_definitions.each do |k, v|
  AttributeDefinition.create(v)
end
