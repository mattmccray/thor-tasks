
# Todo: Add Zepto support for js libs

class Backbone < Thor
  include Thor::Actions
  require 'fileutils'
  require 'open-uri'
  
  
  desc "new [TYPE] [NAME]", "Creates a new backbone class definition"
  def new(type, name)
    if type == 'project'
      say "Creating project #{name}:"
      create_project name
      say "Done."
    else
      puts "COMING SOOOON!"
    end
  end
  
  
  no_tasks do
      
    def build_controller
      FileUtils.mkdir_p './app/controllers'
    end

    def build_model
      FileUtils.mkdir_p './app/models'
    end
    
    def build_view
      FileUtils.mkdir_p './app/views'
    end
    
    def create_project(app_name="untitled", libs=%w(head jquery underscore backbone))
      require 'erb'
      FileUtils.mkdir_p "./#{app_name}/app/lib"
      
      File.open "./#{app_name}/app/lib/backbone.js", 'w' do |file|
        file.write get_latest('backbone')
        say " - #{app_name}/app/lib/backbone.js"
      end
      File.open "./#{app_name}/app/lib/underscore.js", 'w' do |file|
        file.write get_latest('underscore')
        say " - #{app_name}/app/lib/underscore.js"
      end
      
      File.open "./#{app_name}/app/lib/jquery.js", 'w' do |file|
        file.write get_latest('jquery')
        say " - #{app_name}/app/lib/jquery.js"
      end
      
      File.open "./#{app_name}/app/lib/head.js", 'w' do |file|
        file.write get_latest('head')
        say " - #{app_name}/app/lib/head.js"
      end
      
      File.open "./#{app_name}/app/app_main.js", 'w' do |file|
        file.write APP_JS_TEMPLATE
        say " - #{app_name}/app/app_main.js"
      end

      File.open "./#{app_name}/index.html", 'w' do |file|
        template = ERB.new INDEX_HTML_TEMPLATE
        app_name = app_name
        app_libs = libs.reject {|lib| lib == 'head' }
        file.write template.result( binding )
        say " - #{app_name}/index.html"
      end

      File.open "./#{app_name}/Rakefile", 'w' do |file|
        file.write RAKEFILE_TEMPLATE
        say " - #{app_name}/Rakefile"
      end
    end
    
    def get_latest(scriptname)
      # TODO: Verify scriptname is actually in JS_LIBS
      open( JS_LIBS['stable'][scriptname] ).read
    end
    
  end
  
  APP_JS_TEMPLATE =<<-EOS  

function main(DEBUG) {
  window.DEBUG = DEBUG;
  if (main.scripts.length > 0) {
    head.js.call(head, main.scripts);
  }
  head.ready(function(){
    // Initialize your application here.
  });
};

main.scripts = [
  //  'app/controllers/main.js', // <- Add your application scripts here.
];
  
EOS

  INDEX_HTML_TEMPLATE =<<-EOS
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <title><%= app_name %></title>
    <!-- Created by Matt McCray on <%= Time.now %> -->
    <script src="app/lib/head.js"></script>
    <script>
      var DEBUG = (window.location.href.indexOf('file:') == 0), app_main_src = 'app/app_main.js'+ (DEBUG ? '?'+((new Date).getTime()) : '');
      head.js( "app/lib/jquery.js", "app/lib/underscore.js", "app/lib/backbone.js", app_main_src, function(){
        main(DEBUG);
      });
    </script>
  </head>
  <body>
    <header></header>
    <nav></nav>
    <article>
      <section></section>
    </article>
    <aside></aside>
    <footer></footer>
  </body>
</html>
EOS

  RAKEFILE_TEMPLATE = <<-EOS

# Your rake tasks here...

#TODO: Add default tasks for: compress, create_manifest, etc...

EOS

  JS_LIBS = {
    'stable' => {
      'jquery'     => 'http://code.jquery.com/jquery-1.4.4.min.js',
      'backbone'   => 'http://documentcloud.github.com/backbone/backbone-min.js',
      'underscore' => 'http://documentcloud.github.com/underscore/underscore-min.js',
      'head'       => 'https://github.com/headjs/headjs/raw/master/dist/head.min.js'
    },
    'edge'   => {
      'jquery'     => 'http://code.jquery.com/jquery-1.4.4.min.js',
      'backbone'   => 'https://github.com/documentcloud/backbone/raw/master/backbone-min.js',
      'underscore' => 'https://github.com/documentcloud/underscore/raw/master/underscore-min.js',
      'head'       => 'https://github.com/headjs/headjs/raw/master/dist/head.min.js'
    }
  }
end