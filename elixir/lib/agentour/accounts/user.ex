defmodule Agentour.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :name, :string

    has_many :owned_sessions, Agentour.Sessions.Session, foreign_key: :owner_id
    has_many :agents, Agentour.Agents.Agent

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name])
    |> validate_required([:email, :name])
    |> validate_email()
  end

  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :password_confirmation, :name])
    |> validate_required([:email, :password, :password_confirmation, :name])
    |> validate_email()
    |> validate_password()
    |> validate_confirmation(:password)
    |> hash_password()
  end

  def update_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name, :password, :password_confirmation])
    |> validate_required([:email, :name])
    |> validate_email()
    |> maybe_validate_password(attrs)
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 8, max: 72)
    |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    |> validate_format(:password, ~r/[!@#$%^&*(),.?":{}|<>]/, message: "at least one symbol")
  end

  defp maybe_validate_password(changeset, attrs) do
    if attrs["password"] && attrs["password"] != "" do
      changeset
      |> validate_password()
      |> validate_confirmation(:password)
      |> hash_password()
    else
      changeset
    end
  end

  defp hash_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Argon2.hash_pwd_salt(password))

      _ ->
        changeset
    end
  end
end
