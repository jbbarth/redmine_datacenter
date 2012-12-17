module ApachesHelper
  def render_apaches_jump_menu(project,servers,selected)
    html = []
    html << %(<select onchange="if (this.value != '') { window.location = this.value; }">)
    html << %(<option value="#{apaches_path(project)}"> </option>)
    html << options_for_select(servers.map{|server| [server.name, apache_path(project,server)] },
                               :selected => (selected.is_a?(Server) ? apache_path(project,selected) : ""))
    html << %(</select>)
    html.join("\n").html_safe
  end

  def parse_apache_conf(file)
    html = []
    content = File.readlines(file)
    content = content.force_encoding('UTF-8') if content.respond_to?(:force_encoding)
    content.select do |sn|
      sn.strip!
      html << sn if sn.start_with?("ServerName") || sn.start_with?("ServerAlias")
      html << sn if sn.start_with?("ProxyPass ")
    end
    html.map! do |p|
      "<p>#{p}</p>"
    end
    html.join("\n").html_safe
  end
end
