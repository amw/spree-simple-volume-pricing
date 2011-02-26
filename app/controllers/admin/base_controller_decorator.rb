require "render_inheritable"
Admin::BaseController.class_eval do
  render_inheritable
end
