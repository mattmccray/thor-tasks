
class Vhost < Thor
  include Thor::Actions
  
  # TODO: Add a -p / --passenger flag
  desc "new URL [PATH]", "Create new vhost entry"
  def new(url="?", path=".")
    fullpath = File.expand_path path
    url = if url == '?'
      ask "Local url to use:"
    else
      url
    end
    unless url.empty?
      puts "Creating #{url} at #{filepath}"
      puts " - Updating /etc/hosts"
      entry = "\n127.0.0.1       #{url}\n"
      #run "(echo '#{entry}' >> /etc/hosts)", :with=>'sudo'
      File.open '/etc/hosts', 'a' do |hosts|
        hosts << entry
      end
      
      puts " - Updating /etc/apache2/extra/httpd-vhosts.conf"
      entry = """

# Created on #{Time.now} 
<VirtualHost *:80>
    ServerAdmin darthapo@gmail.com
    DocumentRoot #{fullpath}
    ServerName #{url}
    ErrorLog /private/var/log/apache2/#{url}-error_log
    CustomLog /private/var/log/apache2/#{url}-access_log common
</VirtualHost>
      """
      File.open '/etc/apache2/extra/httpd-vhosts.conf', 'a' do |hosts|
        hosts << entry
      end
      
      puts " - Restarting apache"
      run 'apachectl restart'
      
      puts "\nDone."
    else
      puts "Canceled"
    end
  end


  desc "list", "List all vhost entries"
  def list
#    puts run('cat /etc/hosts') 
    lines = run('cat /etc/hosts', :capture=>true, :verbose=>false).to_s.split "\n"
    lines.each do |line|
      line.strip!
      unless  line == '' or line[0] == '#' or line.include?('adobe.com')
        puts line
      end
    end
  end
  
  desc "edit", "Edit hosts and apache vhosts files in Textmate"
  def edit
    run "mate /etc/hosts /etc/apache2/extra/httpd-vhosts.conf"
  end
  
end