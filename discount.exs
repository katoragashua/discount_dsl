defmodule Discount do
  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :discounts, accumulate: true)
      @before_compile unquote(__MODULE__) # @before_compile is a callback that allows us to inject code before the module is compiled
    end
  end

  # The macro __before_compile__ is called just before the module that uses Discount is compiled. It allows us to inject code into that module, in this case, we are defining the apply_discounts function that will apply all the discounts defined in the module.
  defmacro __before_compile__(_env) do
    quote do
      def apply_discounts(product) do
        # IO.puts("Applying discount (#{inspect @discounts})")
          IO.puts("#{inspect @discounts}")

        Enum.reduce(@discounts, product, fn discount, acc ->
          apply_discount_rule(acc, discount)
        end)
      end

      defp apply_discount_rule(product, {_name, condition, action}) do
          if apply(__MODULE__, condition, [product]) do
            apply(__MODULE__, action, [product])
          else
            product
          end
        end
    end
  end

  defmacro discount(name, condition, action) do
    quote bind_quoted: [name: name, condition: condition, action: action] do
      # @discounts {unquote(name), unquote(condition), unquote(action)}
      @discounts {name, condition, action}
    end
  end
end


defmodule Discounts do
  use Discount

  discount :over_100, :is_over_100?, :apply_10_percent_discount
  def is_over_100?(product), do: product.price > 100
  def apply_10_percent_discount(product), do: Map.update!(product, :price, &(&1 * 0.9))

  discount :electronics, :is_electronics?, :apply_5_percent_discount
  def is_electronics?(product), do: product.category == :electronics
  def apply_5_percent_discount(product), do: Map.update!(product, :price, &(&1 * 0.95))

  discount :free_shipping, :is_eligible_for_free_shipping?, :apply_free_shipping
  def is_eligible_for_free_shipping?(product), do: product.price > 50
  # def apply_free_shipping(product), do: Map.put(product, :shipping_cost, 0)
  def apply_free_shipping(product), do: Map.put(product, :free_shipping, true)
end
