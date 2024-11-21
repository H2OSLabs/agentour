ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Agentour.Repo, :manual)

# Load support files
Path.expand("support", __DIR__)
|> Path.join("**/*.ex")
|> Path.wildcard()
|> Enum.each(&Code.require_file/1)
