module NestedListsHelper
  def checked_image(checked=true)
    image_tag 'toggle_check.png' if checked
  end
end
