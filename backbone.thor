
# Todo: Add Zepto support for js libs

class Backbone < Thor
  include Thor::Actions
  require 'fileutils'
  require 'open-uri'
  require 'active_support/inflector'  
  
  desc "new [TYPE] [NAME]", "Creates new backbone files or projects, use 'backbone:new help' for more."
  def new(type=nil, name=nil)
    type = type.nil? ? 'help' : type.downcase
    if name.nil? and type != 'help'
      unless type == 'project' or in_app?
        say "You need to be in a project directory to run this command."
        exit 0
      end
      name = ask "#{type.capitalize} name:"
    end
    case type

      when 'project'
        say "Creating project #{name}:"
        create_project name
      
      when 'controller'
        say "Creating controller #{name}:"
        build_controller name

      when 'model'
        say "Creating model #{name}:"
        build_model name

      when 'view'
        say "Creating view #{name}:"
        build_view name

      else
        say <<-EOS
Usage:
  thor backbone:new TYPE NAME

Types:
 - project
 - controller
 - model (creates a collection too)
 - view
        EOS
      
    end
    say "Done."
  end
  
  desc "update", "Updates app_scripts"
  def update(type='scripts')
    #TODO: Support type=libs -- pull latest libraries
    if in_app?
      say "Updating app_scripts:"
      update_scripts
      
    else
      say "You need to be in a project directory to run this command."
      exit 0
    end
  end
  
  desc "serve", "Serves this directory via WebBrick (since some browser don't handle file:// urls well)"
  method_options :port=>5000
  def serve
    require 'webrick'
    say "Launching server at 127.0.0.1:#{options.port}"
    server = WEBrick::HTTPServer.new(
      :Port          => options.port,
      :FancyIndexing => true,
      :DocumentRoot  => '.',
      :MimeTypes     => {
        'js'     => 'text/plain',
        'coffee' => 'text/plain',
        'css'    => 'text/plain',
        'less'   => 'text/plain',
        'thor'   => 'text/plain',
        'html'   => 'text/html'
      }
    )
    trap('INT') { server.stop }
    server.start
  end
  
  no_tasks do
    
    def update_scripts(project_name=".")
      File.open "#{project_name}/app/app_scripts.js", 'w' do |file|
        template = ERB.new APP_SCRIPTS_TEMPLATE
        app_scripts = []
        %w(controllers models views).each do |type|
          app_scripts << Dir["#{project_name}/app/#{type}/*.js"]
        end
        app_scripts.flatten!
        file.write template.result( binding )
        say " - #{project_name}/app/app_scripts.js"
      end
    end
      
    def build_controller(name)
      require 'erb'
      FileUtils.mkdir_p './app/controllers'
      File.open "./app/controllers/#{name.underscore}.js", 'w' do |file|
        template = ERB.new CONTROLLER_TEMPLATE
        name = name
        className = name.underscore.classify
        file.write template.result( binding )
        say " - ./app/controllers/#{name.underscore}.js"
        update_scripts
      end
    end

    def build_model(name)
      require 'erb'
      FileUtils.mkdir_p './app/models'
      File.open "./app/models/#{name.underscore}.js", 'w' do |file|
        template = ERB.new MODEL_TEMPLATE
        name = name
        className = name.underscore.classify
        file.write template.result( binding )
        say " - ./app/models/#{name.underscore}.js"
        update_scripts
      end
    end
    
    def build_view(name)
      require 'erb'
      FileUtils.mkdir_p './app/views'
      File.open "./app/views/#{name.underscore}.js", 'w' do |file|
        template = ERB.new VIEW_TEMPLATE
        name = name
        className = name.underscore.classify
        file.write template.result( binding )
        say " - ./app/views/#{name.underscore}.js"
        update_scripts
      end
    end
    
    def create_project(app_name="NewProject", libs=%w(head jquery underscore backbone))
      require 'erb'
      FileUtils.mkdir_p "./#{app_name}/app/lib"
      
      libs.each do |lib|
        File.open "./#{app_name}/app/lib/#{lib}.js", 'w' do |file|
          file.write get_latest(lib)
          say " - #{app_name}/app/lib/#{lib}.js"
        end
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
      
      update_scripts "./#{app_name}"
      
    end
    
    def get_latest(scriptname)
      # TODO: Verify scriptname is actually in JS_LIBS
      open( JS_LIBS[scriptname] ).read
    end
    
    def in_app?
      File.exists?('./app') && File.directory?('./app')
    end
  end
  
  APP_JS_TEMPLATE =<<-EOS  

// You can push your own app_scripts here, example:
// app_scripts.push('app/lib/my_plugin');

function app_main(DEBUG) {
  if (app_scripts.length > 0) {
    head.js.apply(head, app_scripts);
  }
  head.ready(function(){
    // Initialize your application here.
    // new App();
    // Then:
    Backbone.history.start();
  });
};
  
EOS

  APP_SCRIPTS_TEMPLATE =<<-EOS
// auto-generated... Add your scripts in app_main.js
var app_scripts = [];
<% app_scripts.each do |script| %>
app_scripts.push('<%= script %>');<% end %>
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
      head.js("app/lib/<%= app_libs.join '.js", "app/lib/' %>.js", "app/app_scripts.js", app_main_src, function(){ app_main(DEBUG); });
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

  CONTROLLER_TEMPLATE = <<-EOS

var <%= className %> = Backbone.Controller.extend({
  
  routes: {
    '': 'index'
  },
  
  index: function() {
    
  }
  
});

EOS

  MODEL_TEMPLATE = <<-EOS

var <%= className %> = Backbone.Model.extend({
  
  
});

var <%= className %>Collection = Backbone.Collection.extend({
  model: <%= className %>
  
});


EOS

  VIEW_TEMPLATE = <<-EOS

var <%= className %> = Backbone.View.extend({
  
  events: {
    
  },
  
  initialize: function() {
    _.bindAll(this, "render");
  },
  
  render: function() {
    
  }
  
});

EOS


  RAKEFILE_TEMPLATE = <<-EOS

# Your rake tasks here...

#TODO: Add default tasks for: compress, create_manifest, etc...

EOS

  JS_LIBS = {
    'jquery'     => 'http://code.jquery.com/jquery-1.4.4.min.js',
    'backbone'   => 'http://documentcloud.github.com/backbone/backbone-min.js',
    'underscore' => 'http://documentcloud.github.com/underscore/underscore-min.js',
    'head'       => 'https://github.com/headjs/headjs/raw/master/dist/head.min.js'
  }
end
