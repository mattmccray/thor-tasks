
class Yui < Thor
  
  desc 'compress [*SOURCES]', 'Compress source with YUI'
  method_options %w(munge -m)=>false
  def compress(*sources)
    begin
      require 'yui/compressor'
    rescue
      puts "Requires YUI Compressor gem:"
      puts "  [sudo] gem install -r yui-compressor"
      exit 1
    end
    sources.each do |source|
      filename = File.basename source
      ext = File.extname source
      filename_min = filename.gsub ext, ".min#{ext}"
      output_path = source.gsub filename, filename_min
      compressor = case ext
        when '.js'
          YUI::JavaScriptCompressor.new( :munge => options.munge? )
        when '.css'
          YUI::CssCompressor.new( ) # Any flags from cmdline?
        else
          puts "Unknown file type."
          nil
      end
      unless compressor.nil?
        puts "Compressing #{'' if options.munge?}#{source} to #{output_path}"
        output = compressor.compress File.read(source)
        File.open output_path, 'w' do |f|
          f.write output
        end
      end
    end
    puts "Done."
  end
  
end