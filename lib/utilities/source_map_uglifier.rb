class SourceMapUglifier
  def compress(string)
    if Rails.env.development? || Rails.env.staging?
      output, sourcemap = Uglifier.new.compile_with_map(string)

      source_maps_folder = File.join(Rails.root, 'public', 'source_maps')
      FileUtils.mkdir_p source_maps_folder

      source_maps_file = Random.new.rand(1000000).to_s + ".js.map"
      File.open(File.join(source_maps_folder, source_maps_file), 'w') do |file|
        file.write(sourcemap)
      end

      sourcemap_comment = "\n//# sourceMappingURL=/source_maps/#{source_maps_file}\n"

      return output + sourcemap_comment
    else
      Uglifier.compile(string)
    end
  end
end
