class VolumePricingHooks < Spree::ThemeSupport::HookListener
  insert_after :admin_product_tabs, :partial => "admin/shared/vp_product_tab"
  insert_after :admin_variant_edit_form, :partial => "admin/variants/volume_prices"
  replace :product_price, :partial => "products/volume_prices"
  insert_after :cart_items, :partial => "orders/cart_volume_discount"
  insert_before :order_details_subtotal, :partial => "shared/order_details_volume_discount"
end
