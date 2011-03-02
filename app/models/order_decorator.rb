Order.class_eval do
  def volume_discount
    line_items.map(&:volume_discount).sum
  end

  # By default volume price is calculated based only on quantity of the current
  # order. If you want to have "Volume Customers" - people who purchase at
  # volume prices, but making multiple orders of smaller quantities you can
  # overwrite this method. You could return the total quantity of given variant
  # the customer bought in the last month. The line items volume price
  # calculation will be adjusted by that number. Like this:
  # variant_starting_quantity + current order quantity
  def variant_starting_quantity variant
    0
  end

  # This is required for Volume Customers
  # It updates item_total when user logs in
  def update_totals_on_user_association
    return unless user_id_changed? || email_changed?

    line_items.each {|li| li.update_volume_discount self}
    update_totals
  end
  before_save :update_totals_on_user_association
end
