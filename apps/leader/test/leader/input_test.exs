defmodule Leader.InputTest do
  use Leader.DataCase

  alias Leader.Input

  describe "leads" do
    alias Leader.Input.Lead

    @valid_attrs %{comments: "some comments", company: "some company", email: "some email", first_name: "some first_name", last_name: "some last_name", phone: "some phone", state: "some state"}
    @update_attrs %{comments: "some updated comments", company: "some updated company", email: "some updated email", first_name: "some updated first_name", last_name: "some updated last_name", phone: "some updated phone", state: "some updated state"}
    @invalid_attrs %{comments: nil, company: nil, email: nil, first_name: nil, last_name: nil, phone: nil, state: nil}

    def lead_fixture(attrs \\ %{}) do
      {:ok, lead} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Input.create_lead()

      lead
    end

    test "list_leads/0 returns all leads" do
      lead = lead_fixture()
      assert Input.list_leads() == [lead]
    end

    test "get_lead!/1 returns the lead with given id" do
      lead = lead_fixture()
      assert Input.get_lead!(lead.id) == lead
    end

    test "create_lead/1 with valid data creates a lead" do
      assert {:ok, %Lead{} = lead} = Input.create_lead(@valid_attrs)
      assert lead.comments == "some comments"
      assert lead.company == "some company"
      assert lead.email == "some email"
      assert lead.first_name == "some first_name"
      assert lead.last_name == "some last_name"
      assert lead.phone == "some phone"
      assert lead.state == "some state"
    end

    test "create_lead/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Input.create_lead(@invalid_attrs)
    end

    test "update_lead/2 with valid data updates the lead" do
      lead = lead_fixture()
      assert {:ok, %Lead{} = lead} = Input.update_lead(lead, @update_attrs)
      assert lead.comments == "some updated comments"
      assert lead.company == "some updated company"
      assert lead.email == "some updated email"
      assert lead.first_name == "some updated first_name"
      assert lead.last_name == "some updated last_name"
      assert lead.phone == "some updated phone"
      assert lead.state == "some updated state"
    end

    test "update_lead/2 with invalid data returns error changeset" do
      lead = lead_fixture()
      assert {:error, %Ecto.Changeset{}} = Input.update_lead(lead, @invalid_attrs)
      assert lead == Input.get_lead!(lead.id)
    end

    test "delete_lead/1 deletes the lead" do
      lead = lead_fixture()
      assert {:ok, %Lead{}} = Input.delete_lead(lead)
      assert_raise Ecto.NoResultsError, fn -> Input.get_lead!(lead.id) end
    end

    test "change_lead/1 returns a lead changeset" do
      lead = lead_fixture()
      assert %Ecto.Changeset{} = Input.change_lead(lead)
    end
  end
end
