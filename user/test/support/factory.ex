defmodule User.Factory do
  alias User.Repo
  alias Ffaker.En.Name
  alias Ffaker.En.Internet

  # Factories

  def build(:user) do
    %User.Model.User{
      email: Internet.email,
      name: Name.name,
      password: Internet.password
    }
  end

  # Helper Functions to Overload Attributes and Insert

  def lacking_param(factory_name, attribute) do
    build(factory_name) |> Map.from_struct |> Map.delete(attribute)
  end

  def params(factory_name) do
    build(factory_name) |> Map.from_struct
  end

  def params(factory_name, attributes) do
    build(factory_name, attributes) |> Map.from_struct
  end

  def build(factory_name, attributes) do
    factory_name |> build() |> struct(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    Repo.insert! build(factory_name, attributes)
  end
end