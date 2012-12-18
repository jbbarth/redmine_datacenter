function toggleVisibility(checkbox_id,section_id) {
  var $section = $("#"+section_id)
  if ($("#"+checkbox_id).is(":checked")) {
    $section.show()
  } else {
    $section.hide()
    $section.find("select").val("")
  }
}

// nested forms
function remove_fields(link) {
  $(link).prev("input[type=hidden]").val("1");
  $(link).closest(".fields").hide();
}

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  $(link).before(content.replace(regexp, new_id));
}
