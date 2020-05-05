defmodule User.Factory do
  alias User.{Repo, Model.User}
  alias Faker.Name
  alias Faker.Internet

  # Factories

  def build(:user) do
    %User{
      email: Internet.email(),
      name: Name.name(),
      password: Internet.user_name()
    }
  end

  # Helper Functions to Overload Attributes and Insert

  def lacking_param(factory_name, attribute) do
    build(factory_name) |> Map.from_struct() |> Map.delete(attribute)
  end

  def params(factory_name) do
    build(factory_name) |> Map.from_struct() |> Map.delete(:id)
  end

  def params(factory_name, attributes) do
    build(factory_name, attributes) |> Map.from_struct()
  end

  def build(factory_name, attributes) do
    factory_name |> build() |> struct(attributes)
  end

  # Insert Factories

  def insert!(factory_name, attributes \\ [])

  def insert!(:user, attributes) do
    params = params(:user, attributes)

    build(:user, params)
    |> Ecto.Changeset.change(Argon2.add_hash(params[:password], hash_key: :password))
    |> Repo.insert!()
  end

  def insert!(factory_name, attributes) do
    Repo.insert!(build(factory_name, attributes))
  end
end
