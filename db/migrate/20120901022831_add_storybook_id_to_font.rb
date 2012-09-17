class AddStorybookIdToFont < ActiveRecord::Migration
  def change
    add_column :assets, :storybook_id, :integer
  end
end
