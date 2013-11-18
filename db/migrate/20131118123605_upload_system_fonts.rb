class UploadSystemFonts < ActiveRecord::Migration
  def up
    if Font.where(:asset_type => 'system').any?
      Font.where(:asset_type => 'system').each do |font|
        file_name = font.font_file_name
        font.font = File.open(File.join(Rails.root, 'db', 'fixtures', 'fonts', file_name))
        font.save
      end
    end
  end

  def down
    Font.where(:asset_type => 'system').update_all(:font => nil)
  end
end
