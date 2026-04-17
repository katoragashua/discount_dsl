defmodule DiscountDslTest do
  use ExUnit.Case

  test "Ensure the module Loads" do
    assert Code.ensure_loaded?(DiscountDSL)
  end

  # 1. Apply discounts to a product if condition is met
  # 2. Apply multiple discounts in sequence to a product if multiple conditions are met
  # 3. Ensure that if no conditions are met, the product remains unchanged
  # 4. Handle edge cases, if price is ₦100, the over_100 discount should not be applied, but the free_shipping discount should be applied
  # 5. Handle edge cases, such as products with missing attributes or invalid data types, gracefully without crashing the application
  # 6. Invalid inputs are handled gracefully

  test "Apply single discount to a product if condition is met" do
    product = %{name: "Redmi Note 10", price: 60, category: :accessories}
    discounted_product = Discounts.apply_discounts(product)
    assert discounted_product.free_shipping == true
    assert discounted_product.price == 60
  end

  test "Apply multiple discounts in sequence to a product if multiple conditions are met" do
    product = %{name: "Redmi Note 10", price: 120, category: :electronics}
    discounted_product = Discounts.apply_discounts(product)
    assert Float.round(discounted_product.price, 1) == 102.6
    assert discounted_product.free_shipping == true
  end

  test "Ensure that if no conditions are met, the product remains unchanged" do
    product = %{name: "The Alchemist", price: 30, category: :books}
    discounted_product = Discounts.apply_discounts(product)
    assert discounted_product == product
  end

  test "Handle edge cases, if price is ₦100, the over_100 discount should not be applied, but the free_shipping discount should be applied" do
    product = %{name: "Nintendo Switch", price: 100, category: :misc}
    discounted_product = Discounts.apply_discounts(product)
    assert discounted_product.price == 100
    assert discounted_product.free_shipping == true
  end

  test "Handle edge cases, such as products with missing attributes or invalid data types, gracefully without crashing the application" do
    product = %{name: "Unknown Product", price: "not a number", category: :unknown}
    discounted_product = Discounts.apply_discounts(product)
    assert discounted_product == product
  end

  test "Invalid inputs are handled gracefully" do
    product = %{name: "Invalid Product", price: nil, category: :invalid}
    discounted_product = Discounts.apply_discounts(product)
    assert discounted_product == product
  end
end
