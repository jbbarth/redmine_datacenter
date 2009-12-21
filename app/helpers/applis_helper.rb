module ApplisHelper
  def links_to_applis(applis)
    applis.sort_by(&:name).map do |appli|
      link_to(appli.name, appli)
    end.join(", ")
  end
end
