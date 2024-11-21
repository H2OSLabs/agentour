defmodule Agentour.AccountsTest do
  use Agentour.DataCase

  alias Agentour.Accounts
  alias Agentour.Accounts.User

  describe "users" do
    @valid_attrs %{
      email: "test@email.com",
      name: "test_account",
      password: "rdxD39iPd3#HiM",
      password_confirmation: "rdxD39iPd3#HiM"
    }
    @invalid_attrs %{email: nil, password: nil, name: nil}

    test "register_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.register_user(@valid_attrs)
      assert user.email == "test@email.com"
      assert user.name == "test_account"
      assert Argon2.verify_pass("rdxD39iPd3#HiM", user.password_hash)
    end

    test "register_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.register_user(@invalid_attrs)
    end

    test "authenticate_user/2 with valid credentials" do
      {:ok, user} = Accounts.register_user(@valid_attrs)
      assert {:ok, authenticated_user} = Accounts.authenticate_user("test@email.com", "rdxD39iPd3#HiM")
      assert authenticated_user.id == user.id
    end

    test "authenticate_user/2 with invalid password" do
      {:ok, _user} = Accounts.register_user(@valid_attrs)
      assert {:error, :bad_password} = Accounts.authenticate_user("test@email.com", "wrong_password")
    end

    test "authenticate_user/2 with invalid email" do
      assert {:error, :bad_email} = Accounts.authenticate_user("wrong@email.com", "rdxD39iPd3#HiM")
    end
  end
end
