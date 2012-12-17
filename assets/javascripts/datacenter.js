function toggleVisibility(checkbox_id,section_id) {
  var $section = $("#"+section_id)
  if ($("#"+checkbox_id).is(":checked")) {
    $section.show()
  } else {
    $section.hide()
    $section.find("select").val("")
  }
}
