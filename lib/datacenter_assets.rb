class DatacenterAssets < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context)
    stylesheet_link_tag("datacenter", {:plugin => "redmine_datacenter"})
  end
end
Redmine::Hook.add_listener(DatacenterAssets)
