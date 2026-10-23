# Marca los campos con error con una clase en vez de envolverlos en un <div> (que rompe el diseño).
ActionView::Base.field_error_proc = proc do |html_tag, _instance|
  if html_tag.start_with?("<label")
    html_tag
  else
    html_tag.sub(/class="/, 'class="has-error ').html_safe
  end
end
