Simple Volume Pricing
=====================

Simple Volume Pricing is an extension to Spree (a complete open source commerce
solution for Ruby on Rails) that allows order quantity to determine the price
for a particular product variant. For instance the variant's starting price
might be $19.99, but $18 if customer orders 5 or more units or $15 if customer
orders 20 or more.

Each VolumePrice contains the following values:

1. **Variant:** Each VolumePrice is associated with a _Variant_, which is used
   to link products to particular prices.
2. **Starting Quantity:** The minimum quantity for which this VolumePrice
   applies. If there is a VolumePrice with higher starting quantity that still
   applies to this order, it will be used instead.
3. **Price:** The price of the variant if the line item quantity is big enough
   for this VolumePrice to apply.

Examples
========
Rails T-Shirt variant has a price of $19.99. Consider the following examples of
volume prices:

       Variant             Starting Quantity  Price
       ---------------------------------------------
       Rails T-Shirt       5                  18.00
       Rails T-Shirt       20                 15.00

## Example 1

Cart Contents:

       Product                Quantity       Price       Total
       ----------------------------------------------------------------
       Rails T-Shirt          1              19.99       19.99

Order details:

       Volume Discount:     0.00
       Subtotal:           19.99

## Example 2

Cart Contents:

       Product                Quantity       Price       Total
       ----------------------------------------------------------------
       Rails T-Shirt          5              19.99       99.95

Order details:

       Volume Discount:    -9.95 # 5 * (19.99 - 18)
       Subtotal:           90.00

## Example 3

Cart Contents:

      Product                Quantity       Price       Total
      ----------------------------------------------------------------
      Rails T-Shirt          6              19.99       119.94

Order details:

       Volume Discount:   -11.94 # 6 * (19.99 - 18)
       Subtotal:          108.00

## Example 4

Cart Contents:

      Product                Quantity       Price       Total
      ----------------------------------------------------------------
      Rails T-Shirt          20             19.99       399.80

Order details:

       Volume Discount:   -99.80 # 20 * (19.99 - 15)
       Subtotal:          300.00



Why is it simple
================

This extension is called Simple to differentiate it from [another volume pricing
extension](https://github.com/railsdog/spree-volume-pricing) created and
maintained by the Spree Core team at RailsDog.

Simple Volume Pricing is simple to use, but gives you the same level of control.
It doesn't require you to define ranges, assign them a human readable
description or arrange them in order manually. You just slice the quantity
continuum with points (starting quantity) between 1 and infinity. The volume
price with highest starting quantity is automatically open ended. If you need to
end that range just add another point with the variant's original price.

The original extension had also some issues, such as defining overlapping
ranges. The models were unnecessarily complicated. Why `acts_as_list` if you can
just order volume prices by their lower quantity range end?


Volume Customers
================

By default volume prices are calculated based only on the quantity of the
current order. But your business might want to allow customers to buy huge
volumes over a number of smaller orders. If you want to include quantities from
customer's past orders in volume price calculation you can overwrite
`Order::variant_starting_quantity(variant)` method. By default it returns 0.

## Example

If you want to calculate customer's volume discount based on his order history
from last 31 days just add this to your site's code:

    Order.class_eval do
      def variant_starting_quantity variant
        orders = Order.complete.by_customer(self.email).between(self.created_at - 31.days, self.created_at + 1.day)
        orders.map do |o|
          o.line_items.select {|li| li.variant_id == variant.id}.map(&:quantity).sum
        end.sum
      end
    end

Assuming the same volume prices configuration as above. First order:

      Product                Quantity       Price       Total
      ----------------------------------------------------------------
      Rails T-Shirt          8              19.99       159.92

Order details:

       Volume Discount:    -15.92 # 8 * (19.99 - 18)
       Subtotal:           144.00


Next order during the next 31 days:

      Product                Quantity       Price       Total
      ----------------------------------------------------------------
      Rails T-Shirt          4              19.99       79.96

Order details:

       Volume Discount:     -7.96 # 4 * (19.99 - 18)
       Subtotal:            72.00


Additional Notes
================

* The volume discount is calculated by applying the discount price to all
  ordered units of a particular variant. It does not (yet) apply different
  prices for the portion of the quantity that falls within a particular range.
  Although I plan to support such option.

Authors
=======

This extension is based on
[spree-volume-pricing](https://github.com/railsdog/spree-volume-pricing)
extension. It was rewritten by Adam Wróbel of Flux Inc, but there are some bits
by the original authors in the initial commit.
