# Adapted from https://github.com/mexitek/redmine_wiki_html_util
# Credits go to Arlo Carreon
# See: http://www.arlocarreon.com/blog/redmine/redmine-wiki-html-utility/

Redmine::WikiFormatting::Macros.register do
  desc "Embed raw html"
  macro :html do |obj, args, text|
    text.html_safe
  end

  desc "Embed raw css"
  macro :css do |obj, args, text|
    text.gsub!(/\[/,'{')
    text.gsub!(/\]/,'}')
    text.gsub!(/<\/?[^>]*>/, "")
    "<style type=\"text/css\">#{text}</style>".html_safe
  end

  desc "Insert a CSS file into the DOM"
  macro :css_url do |obj, args|
    "<script> var head = document.getElementsByTagName('head')[0], t = document.createElement('link'); t.href = #{args[0]}; t.media='all'; t.rel='stylesheet'; head.appendChild(t); </script>".html_safe
  end

  desc "Embed raw js"
  macro :js do |obj, args, text|
    "<script>#{text}</script>".html_safe
  end

  desc "Insert a JS file into the DOM"
  macro :js_url do |obj, args|
    "<script> var head = document.getElementsByTagName('head')[0], t = document.createElement('script'); t.src = #{args[0]}; t.type='text/javascript'; head.appendChild(t); </script>".html_safe
  end
end
