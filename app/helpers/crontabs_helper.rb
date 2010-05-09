module CrontabsHelper
  
  #see: man 5 crontab
  CRONTAB_KEYWORDS = {
    "@reboot" 	=> %Q{Run once, at startup.},
    "@yearly" 	=> %Q{Run once a year, "0 0 1 1 *},
    "@annually"	=> %Q{(same as @yearly)},
    "@monthly" 	=> %Q{Run once a month, "0 0 1 * *"},
    "@weekly" 	=> %Q{Run once a week, "0 0 * * 0"},
    "@daily" 	=> %Q{Run once a day, "0 0 * * *"},
    "@midnight"	=> %Q{(same as @daily)},
    "@hourly" 	=> %Q{Run once an hour, "0 * * * *"}
  }

  def format_cron_line(line)
    html = ""
    line_a = line.split(/\s+/)
    if line_a.first.match(/^@/) && CRONTAB_KEYWORDS.has_key?(line_a.first)
      keyword = line_a.shift
      html << '<td colspan="5">'+keyword+' <em>'+CRONTAB_KEYWORDS[keyword]+'</em></td>'
      html << "<td>"+line_a.shift+"</td>" #user..
      html << '<td class="croncommand">'+line_a.join(" ")+"</td>"
    else
      html << line_a.slice(0,6).map{|l| "<td>#{l}</td>"}.join
      html << '<td class="croncommand">'+line_a.slice(6,line_a.length).join(" ")+"</td>"
    end
    html
  end

  def render_crontabs_jump_menu(project,servers,selected)
    html = []
    html << %(<select onchange="if (this.value != '') { window.location = this.value; }">)
    html << %(<option value="#{crontabs_path(project)}"> </option>)
    html << options_for_select(servers.map{|server| [server.name, crontab_path(project,server)] },
                               :selected => (selected.is_a?(Server) ? crontab_path(project,selected) : ""))
    html << %(</select>)
    html.join("\n")
  end
end
