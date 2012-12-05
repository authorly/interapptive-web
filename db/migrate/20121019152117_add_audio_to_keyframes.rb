class AddAudioToKeyframes < ActiveRecord::Migration
  def change
    add_column :keyframes, :audio, :string
  end
end
