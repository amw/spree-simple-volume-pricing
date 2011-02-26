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
       Rails T-Shirt          1              20.99       19.99

## Example 2

Cart Contents:

       Product                Quantity       Price       Total
       ----------------------------------------------------------------
       Rails T-Shirt          5              18.00       90.00

## Example 3

Cart Contents:

      Product                Quantity       Price       Total
      ----------------------------------------------------------------
      Rails T-Shirt          6              18.00       108.00

## Example 4

Cart Contents:

      Product                Quantity       Price       Total
      ----------------------------------------------------------------
      Rails T-Shirt          20             15.00       300.00


Why is it simple
================

This extension is called Simple to differentiate it from another volume pricing
extension created and maintained by the Spree Core team at RailsDog:
https://github.com/railsdog/spree-volume-pricing

Simple Volume Pricing is simple to use, but gives you the same level of control.
It doesn't require you to define ranges, assign them a human readable
description or arrange them in order manually. You just slice the quantity
continuum with points (starting quantity) between 1 and infinity. The volume
price with highest starting quantity is automatically open ended. If you need to
end that range just add another point with the variant's original price.

The original extension had also some issues, such as defining overlapping
ranges. The models were unnecessarily complicated. Why `acts_as_list` if you can
just order volume prices by their lower quantity range end?

Additional Notes
================

* The volume price is applied based on the total quantity ordered for
  a particular variant. It does not (yet) apply different prices for the portion
  of the quantity that falls within a particular range. Although I plan to
  support such option.
