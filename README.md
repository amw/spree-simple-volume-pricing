# Simple Volume Pricing
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

Variant objects get a new boolean property
`progressive_volume_discount` to select between two available discount
strategies.

Product objects get a boolean property
`variants_use_master_discount` that controls whether the volume is calculated
per product or separately for each of it's variants.

If you want to see the extension's UI there are
[screenshots](https://github.com/amw/spree-simple-volume-pricing/wiki/Screenshots)
available.


# Installation
Currently I do not release this extension as a gem. To use it add this to your
Gemfile:

    gem "spree_simple_volume_pricing", :git => "https://github.com/amw/spree-simple-volume-pricing.git", :tag => "v3.0.0"


# Options

## Single volume discount for all variants
By default volume discount is configured and calculated separately for all
variants. There is a per-product preference that you can use if you want it to
be calculated based on the sum of product's variants in the cart. This implies
that the starting price and volume prices that were set for particular variants
will be ignored and, instead, the product's own pricing scheme will be used.


## Uniform vs Progressive volume discount
This extension supports two discount strategies. Uniform volume discount selects
one VolumePrice based on ordered quantity and applies it to all ordered units.
Progressive volume discount applies different VolumePrices to different portions
of the item's quantity. This means that you can charge i.e. $15 for the first
three units in the cart, $13 for the next five and $10 for all additional.

Some people find progressive volume discount easier to configure. With prices
applied uniformly your customers often end up in situations when it's cheaper to
buy X + Y units than just X (a substantial price drop can neglect an added
quantity).


### Uniform Volume Discount examples
Rails T-Shirt variant has a price of $19.99. Consider the following examples of
volume prices:

       Variant             Starting Quantity  Price
       ---------------------------------------------
       Rails T-Shirt       5                  18.00
       Rails T-Shirt       20                 15.00

#### Example 1
Cart Contents:

       Product                Quantity       Price       Total
       ----------------------------------------------------------------
       Rails T-Shirt          1              19.99       19.99

Order details:

       Subtotal:           19.99

#### Example 2
Cart Contents:

       Product                Quantity       Price       Total
       ----------------------------------------------------------------
       Rails T-Shirt          5              19.99       99.95

Order details:

       Volume Discount:    -9.95 # 5 * (19.99 - 18.00)
       Subtotal:           90.00 # 5 * 18.00

#### Example 3
Cart Contents:

       Product                Quantity       Price       Total
       ----------------------------------------------------------------
       Rails T-Shirt          6              19.99       119.94

Order details:

       Volume Discount:   -11.94 # 6 * (19.99 - 18.00)
       Subtotal:          108.00 # 6 * 18.00

#### Example 4
Cart Contents:

       Product                Quantity       Price       Total
       ----------------------------------------------------------------
       Rails T-Shirt          20             19.99       399.80

Order details:

       Volume Discount:   -99.80 # 20 * (19.99 - 15.00)
       Subtotal:          300.00 # 20 * 15.00


### Progressive Volume Discount examples
Given the same volume prices configuration as in uniform discount examples.

#### Example 1
Cart Contents:

       Product                Quantity       Price       Total
       ----------------------------------------------------------------
       Rails T-Shirt          6              19.99       119.94

Order details:

       Volume Discount:    -3.98
       Subtotal:          115.96 # 4 * 19.99 + 2 * 18.00

#### Example 2
Cart Contents:

       Product                Quantity       Price       Total
       ----------------------------------------------------------------
       Rails T-Shirt          25             19.99       499.75

Order details:

       Volume Discount:   -59.79
       Subtotal:          439.96 # 4 * 19.99 + 15 * 18.00 + 6 * 15.00


# Why is it simple
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


# Volume Customers

By default volume prices are calculated based only on the quantity of the
current order. But your business might want to allow customers to buy huge
volumes over a number of smaller orders. If you want to include quantities from
customer's past orders in volume price calculation you can overwrite
`Order::variant_starting_quantity(variant)` method. By default it returns 0.

#### Example
If you want to calculate customer's volume discount based on his order history
from last 31 days just add this to your site's code:

    Order.class_eval do
      def variants_starting_quantity *variant_ids
        orders = Order.complete.by_customer(self.email).between(self.created_at - 1.month + 1.day, self.created_at + 1.day)
        orders.map do |o|
          o.line_items.select do |li|
            variant_ids.include? li.variant_id
          end.map(&:quantity).sum
        end.sum
      end
    end

Assuming the same volume prices configuration as above and uniform volume
discount strategy. First order:

       Product                Quantity       Price       Total
       ----------------------------------------------------------------
       Rails T-Shirt          8              19.99       159.92

Order details:

       Volume Discount:    -15.92 # 8 * (19.99 - 18.00)
       Subtotal:           144.00 # 8 * 18.00


Next order during the next 31 days:

       Product                Quantity       Price       Total
       ----------------------------------------------------------------
       Rails T-Shirt          4              19.99       79.96

Order details:

       Volume Discount:     -7.96 # 4 * (19.99 - 18.00)
       Subtotal:            72.00 # 4 * 18.00


# Authors
This extension is based on
[spree-volume-pricing](https://github.com/railsdog/spree-volume-pricing)
extension. It was rewritten by Adam Wróbel of Flux Inc, but there are some bits
by the original authors in the initial commit.
