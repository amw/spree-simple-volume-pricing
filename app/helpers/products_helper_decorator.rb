ProductsHelper.module_eval do
  def variant_price_diff_with_volume_discount variant
    return if variant.product.variants_use_master_discount
    variant_price_diff_without_volume_discount variant
  end
  alias_method_chain :variant_price_diff, :volume_discount
end unless ProductsHelper.instance_methods.include? \
             :variant_price_diff_with_volume_discount
