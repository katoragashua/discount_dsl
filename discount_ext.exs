defmodule DiscountExt do
  defmacro extend do
    quote do
      import unquote(__MODULE__)

      def apply_discounts(product) do
        IO.puts("Applying discounts to #{product.name}")
        case product do
          product when product.price > 100  -> Map.update!(product, :price, &(&1 * 0.9)) # 10% discount
          product when product.price > 50   -> Map.update!(product, :price, &(&1 * 0.95)) # 5% discount
          _ -> product
        end
      end
    end
  end
end


defmodule Product do
  require DiscountExt
  DiscountExt.extend
end

# defmodule DiscountExt do
#   defmacro __using__(_) do
#     quote do
#       import unquote(__MODULE__)

#       def apply_discounts(product) do
#         IO.puts("Applying discounts to #{product.name}")
#         case product do
#           product when product.price > 100  -> Map.update!(product, :price, &(&1 * 0.9)) # 10% discount
#           product when product.price > 50   -> Map.update!(product, :price, &(&1 * 0.95)) # 5% discount
#           _ -> product
#         end
#       end
#     end
#   end
# end


# defmodule Product do
#     use DiscountExt
# end
