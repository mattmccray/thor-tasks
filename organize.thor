# organize.thor
#
# By M@ McCray -- www.mattmccray.com (matt at elucidata dot net)
#
# Usage:
#
#  thor organize:files ~/Downloads
#


require 'rubygems'
require 'rake'

class Organize < Thor

  EXTENSIONS_FOR_TYPE = {
    "Applications" => %w(.app .jar .exe .pkg .mpkg .air),
    "Archives"    => %w(.dmg .zip .rar .sit .sitx .tar .gz .bz2),
    "Audio"       => %w(.wav .mp3 .ogg .m3u .m4a .wma),
    "Code"        => %w(.sh .rb .js .java .c .coffee .m .h .py .php .css .haml .sass .erb .html .rhtml .xhtml .htm  .bat .patch .diff .gem .xul .shy .sql .nib .xib .cib .j .sj .nu .rake .thor .nuke .mxml .less .scss),
    "Comics"      => %w(.cbr .cbz),
    "Data"        => %w(.xml .yaml .yml .json .sqlite .sqlite3 .db .csv .opml),
    "Documents"   => %w(.pdf .doc .ppt .txt .text .rtf .rtfd .xls .oo3 .tables .taskpaper .textile .markdown .graffle .pages .vpdoc),
    "Folders"     => [],
    "Fonts"       => %w(.ttf .otf .suit),
    "Links"       => %w(.webloc),
    "Images"      => %w(.jpg .jpe .jpeg .png .gif .bmp .svg .psd .ai .ps .ico .icns .lineform .eps .acorn .pxm .ptn .fla .tiff),
    "Models"      => %w(.3ds .blend .dxf .skp .obj),
    "Other"       => [],
    "Scripts"     => %w(.script .celtx .scriv),
    "Torrents"    => %w(.torrent),
    "Videos"      => %w(.avi .mvk .mov .wmv .flv .mp4 .mpg .mpeg .m4v .qtz)
  } #unless defined? EXTENSIONS_FOR_TYPE

  # The character to postfix any clashing filenames with...
  FILE_POSTFIX = "_" #unless defined? FILE_POSTFIX
  
  
  desc "files [FOLDER]", "Organize files in FOLDER based on file type"
  method_options :postfix => "_", :force => :boolean, :verbose => :boolean

  def files(folder)
    full_path = File.expand_path folder
    if File.exists?(full_path)
      if options.force? or yes?(" > This will move all loose files in #{full_path} (postfix: #{options.postfix}). Continue?")
        puts "Organizing folder: #{full_path}"
        organize_files_within( full_path, options.verbose?, options.postfix )
        puts "Done."
      else
        puts "OK, don't worry about it."
      end
    else
      puts "Path does not exist! (#{full_path})"
    end
  end
  
  
  no_tasks do
  
    # Helper:
    def organize_files_within(folder, verbose=false, postfix=FILE_POSTFIX)
      types_by_ext = {}

      # Create organizational folders, and invert Category/Extension hash
      EXTENSIONS_FOR_TYPE.each do |ftype, exts|
        folder_name = File.join(folder, ftype)
        exts.each do |ext|
          types_by_ext[ext.downcase] = folder_name
        end
      end

      FileList[folder + "/*"].each do |downloaded_file|
        file = File.expand_path(downloaded_file)

        # Skip our organization folders...
        next if File.directory?(file) && EXTENSIONS_FOR_TYPE.keys.include?( File.basename(file) )

        # Figure out our target folder...
        move_to = if types_by_ext.keys.include?( File.extname(file).downcase )
                    types_by_ext[ File.extname(file).downcase ] # Folder by extension...
                  elsif File.directory?(file)
                    File.join(folder, "Folders") # Move folders into correct place...
                  else
                    File.join(folder, 'Other') # Otherwise, put in 'Other' folder...
                  end

        # Create organizational folder, unless it already exists...
        FileUtils.mkdir( move_to, :verbose => verbose ) unless File.exists?( move_to )

        # Ensure the filename doesn't clash with an already organized file...
        file_ext  = File.extname(file)           # ie. ".js"
        file_base = File.basename(file)          # ie. "test.js"
        file_name = file_base.gsub(file_ext, '') # ie. "test"
        file_target = File.join(move_to, file_base)

        while File.exists?(file_target)
          file_name = "#{file_name}#{postfix}"
          file_target = File.join(move_to, "#{file_name}#{file_ext}")
        end

        # Move the file...
        FileUtils.mv(file, file_target, :verbose => verbose)
      end
    end
  
  end
  
end
