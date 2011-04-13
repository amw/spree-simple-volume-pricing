module ActiveRecord::Persistence
  # Update attributes of a record without callbacks, validations etc.
  def update_attributes_without_callbacks(attributes)
    self.send(:attributes=, attributes, false)
    self.class.update_all(attributes, { :id => id }) if id
  end
end
