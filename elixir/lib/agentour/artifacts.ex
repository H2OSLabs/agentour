defmodule Agentour.Artifacts do
  import Ecto.Query
  alias Agentour.Repo
  alias Agentour.Artifacts.Artifact

  def list_session_artifacts(session_id) do
    from(a in Artifact,
      where: a.session_id == ^session_id,
      order_by: [desc: a.inserted_at]
    )
    |> Repo.all()
  end

  def get_artifact!(id), do: Repo.get!(Artifact, id)

  def create_artifact(attrs \\ %{}) do
    %Artifact{}
    |> Artifact.changeset(attrs)
    |> Repo.insert()
  end

  def update_artifact(%Artifact{} = artifact, attrs) do
    artifact
    |> Artifact.changeset(attrs)
    |> Repo.update()
  end

  def delete_artifact(%Artifact{} = artifact) do
    Repo.delete(artifact)
  end

  def change_artifact(%Artifact{} = artifact, attrs \\ %{}) do
    Artifact.changeset(artifact, attrs)
  end
end
