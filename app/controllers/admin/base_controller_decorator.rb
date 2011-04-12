require "render_inheritable"
Admin::BaseController.class_eval do
  render_inheritable
end unless Admin::BaseController.included_modules.include? RenderInheritable
