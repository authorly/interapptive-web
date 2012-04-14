class CreateKeyframeTexts < ActiveRecord::Migration
  def change
    create_table :keyframe_texts do |t|
      t.references :keyframe
      t.text :content
      t.string :content_highlight_times

      t.timestamps
    end

    add_index :keyframe_texts, :keyframe_id
  end
end
