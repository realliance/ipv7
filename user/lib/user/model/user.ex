defmodule User.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      @primary_key {:id, :binary_id, autogenerate: true}
    end
  end
end

defmodule User.Model.User do
  use User.Schema

  schema "users" do
    field(:email)
    field(:name)
    field(:password)
    field(:points, :integer, default: 0)
  end

  def changeset(action, user, params \\ %{})

  def changeset(:register, user, params) do
    user
    |> Ecto.Changeset.cast(params, [:email, :name, :password])
    |> put_pass_hash
    |> Ecto.Changeset.validate_required([:email, :name, :password])
  end

  def changeset(:update, user, params) do
    user
    |> Ecto.Changeset.cast(params, [:email, :name, :password])
  end

  def changeset(:award_points, user, params) do
    user
    |> Ecto.Changeset.cast(params, [:points])
  end

  def put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    Ecto.Changeset.change(changeset, Argon2.add_hash(password, hash_key: :password))
  end

  def put_pass_hash(changeset), do: changeset
end
