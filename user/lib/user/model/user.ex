defmodule User.Model.User do
  use Ecto.Schema

  schema "users" do
    field :email
    field :name
    field :password
    field :points, :integer, default: 0
  end

  def changeset(action, user, params \\ %{})

  def changeset(:register, user, params) do
    user
    |> Ecto.Changeset.cast(params, [:email, :name, :password])
    |> Ecto.Changeset.validate_required([:email, :name, :password])
  end

  def changeset(:update, user, params) do
    user
    |> Ecto.Changeset.cast(params, [:email, :name, :password, :points])
    |> Ecto.Changeset.validate_required([:email, :name, :password, :points])
  end
end