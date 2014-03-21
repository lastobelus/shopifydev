module InlineErrorHelper
  def inline_error(obj, attr)
    return "" if obj.nil? || obj.errors[attr].empty
    content_tag(:small, obj.errors[attr].join(', '), class: 'error')
  end
end