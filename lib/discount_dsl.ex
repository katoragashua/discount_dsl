defmodule DiscountDSL do
  defmacro __using__(_options) do
    quote do
      # This allows us to use the discount macro in the module that needs to define discounts without having to prefix it with Discount.
      import unquote(__MODULE__)

      # This registers a module attribute called @discounts that will accumulate values, meaning that every time we define a discount, it will be added to the list of discounts instead of overwriting it.
      Module.register_attribute(__MODULE__, :discounts, accumulate: true)
      # @before_compile is a callback that allows us to inject code before the module is compiled
      @before_compile unquote(__MODULE__)
    end
  end

  # The macro __before_compile__ is called just before the module that uses Discount is compiled. It allows us to inject code into that module, in this case, we are defining the apply_discounts function that will apply all the discounts defined in the module.
  defmacro __before_compile__(_env) do
    quote do
      # def apply_discounts(product) do
      #   # IO.puts("#{inspect @discounts}")

      #   discounted_product =
      #     Enum.reduce(@discounts, product, fn discount, acc ->
      #       apply_discount_rule(acc, discount)
      #     end)
      #   discounted_product
      # end

      #   discounted_product =
      #     Enum.reduce(@discounts, product, fn discount, acc ->
      #       apply_discount_rule(acc, discount)
      #       # {name, condition, action} = discount
      #       # IO.puts("Checking discount: #{name}")
      #       # if apply(__MODULE__, condition, [acc]) do
      #       #   apply(__MODULE__, action, [acc])
      #       #   IO.puts("Applied discount: #{name}")
      #       # else
      #       #   acc # If the condition is not met, we return the product unchanged
      #       # end
      #     end)

      #   discounted_product
      # end

      def apply_discounts(product) do
        # IO.inspect(@discounts)

        @discounts
        |> Enum.reduce(product, fn discount, acc ->
          {name, require_fields, condition, action} = discount

          if validate_product(acc, require_fields) do
            case apply(__MODULE__, condition, [acc]) do
              true ->
                # apply(__MODULE__, action, [acc]) |> round_product_price()

                try do
                  apply(__MODULE__, action, [acc])
                rescue
                  e ->
                    # IO.warn("Failed to apply discount #{name}: #{Exception.message(e)}")
                    acc
                end

              false ->
                acc
            end
          else
            acc
          end
        end)
      end

      # defp apply_discount_rule(product, {_name, require_fields, condition, action}) do
      #   if validate_product(product, require_fields) do
      #     case apply(__MODULE__, condition, [product]) do
      #       true -> apply(__MODULE__, action, [product])
      #       false -> product
      #     end
      #   else
      #     product
      #   end
      # end

      defp validate_product(product, require_fields) do
        require_fields
        |> Enum.all?(fn field -> Map.has_key?(product, field) end)
      end

      defp round_product_price(product) do
        product = %{product | price: Float.round(product.price * 1.0, 2)}
        product
      end
    end
  end

  defmacro discount(name, require_fields, condition, action) do
    quote bind_quoted: [
            name: name,
            require_fields: require_fields,
            condition: condition,
            action: action
          ] do
      # @discounts {unquote(name), unquote(condition), unquote(action)}
      @discounts {name, require_fields, condition, action}
    end
  end
end
