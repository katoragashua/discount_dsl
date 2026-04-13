defmodule Discount do
  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      
    end
  end
end
