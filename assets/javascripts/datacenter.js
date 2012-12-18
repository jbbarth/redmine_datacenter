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

//multiselect expansion
function toggle_multi_select_datacenter(field_id) {
  toggleMultiSelect($("#"+field_id))
}

function toggle_servers_select(id,linkid) {
  value = flat_getValue(id);
  if (value.indexOf("Instance") >= 0) {
    $("#"+linkid).show()
  } else {
    $("#"+linkid).hide()
  }
}
function flat_getValue(id) {
  value = $("#"+id).val()
  if (value instanceof Array) {
    value = value.join(',')
  }
  return value
}

//select servers from application instance in issues/form
$(function() {
  $("#select-servers-link").live("click", function() {
    $.getScript(this.href+"?ids="+flat_getValue("issue_appli_instance_ids"))
    return false
  })
})
