class AddAutoAlignStateToKeyframes < ActiveRecord::Migration
  def change
    add_column :keyframes, :auto_align_state, :string, :default => 'undone'
  end
end
