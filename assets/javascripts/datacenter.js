function toggleVisibility(checkbox_id,section_id) {
  if ($(checkbox_id).checked) {
    $(section_id).show();
  } else {
    $(section_id).hide();
    $(section_id).firstDescendant('select').value="";
  }
}
