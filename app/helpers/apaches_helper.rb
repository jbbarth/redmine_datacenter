module ApachesHelper
  def render_apaches_jump_menu(project,servers,selected)
    html = []
    html << %(<select onchange="if (this.value != '') { window.location = this.value; }">)
    html << %(<option value="#{apaches_path(project)}"> </option>)
    html << options_for_select(servers.map{|server| [server.name, apache_path(project,server)] },
                               :selected => (selected.is_a?(Server) ? apache_path(project,selected) : ""))
    html << %(</select>)
    html.join("\n")
  end

  def parse_apache_conf(file)
    html = []
    content = File.readlines(file)
    content.grep(/^\s*Server(Name|Alias)/).each do |sn|
      html << sn.strip
    end
    content.grep(/^\s*ProxyPass\s/).each do |pp|
      html << pp.strip
    end
    html.map! do |p|
      "<p>#{p}</p>"
    end
    html.join("\n")
  end
end
