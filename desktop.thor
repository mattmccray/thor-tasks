
module Desktop

  class Icons < Thor
    include Thor::Actions

    desc "show", "Show the icons on your (Mac) desktop"
    def show
      run "defaults write com.apple.finder CreateDesktop -bool true"
      run "killall Finder"
      puts "Done."
    end
    
    desc "hide", "Hide the icons on your (Mac) desktop"
    def hide
      run "defaults write com.apple.finder CreateDesktop -bool false"
      run "killall Finder"
      puts "Done."
    end
  
  end

end