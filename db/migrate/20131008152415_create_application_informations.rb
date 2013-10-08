class CreateApplicationInformations < ActiveRecord::Migration
  def up
    create_table :application_informations do |t|
      t.integer :storybook_id
      t.text    :description
      t.string  :icon
      t.date    :available_from
      t.string  :price_tier
      t.text    :content_description
      t.boolean :for_kids
      t.string  :keywords

      t.timestamps
    end

    Storybook.find_each do |storybook|
      tier = nil
      info = ApplicationInformation.new({
        storybook_id: storybook.id,
        description:  storybook.description,
      })
      info.save(validate: false)
    end

    change_table :storybooks do |t|
      t.remove :description
      t.remove :price
    end
  end

  def down
    change_table :storybooks do |t|
      t.text     "description"
      t.decimal  "price", :precision => 8, :scale => 2
    end

    ApplicationInformation.find_each do |info|
      storybook = Storybook.find(info.storybook_id)
      storybook.description = info.description
      storybook.save(validate: false)
    end

    drop_table :application_informations
  end

end
