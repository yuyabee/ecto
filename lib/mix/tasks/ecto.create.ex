defmodule Mix.Tasks.Ecto.Create do
  use Mix.Task
  import Mix.Ecto

  @shortdoc "Create the storage for the repo"
  @recursive true

  @moduledoc """
  Create the storage for the repository.

  ## Examples

      mix ecto.create
      mix ecto.create -r Custom.Repo

  ## Command line options

    * `-r`, `--repo` - the repo to create (defaults to `YourApp.Repo`)
    * `--no-compile` - do not compile before creating
    * `--quiet` - do not log output

  """

  @doc false
  def run(args) do
    repos = parse_repo(args)
    {opts, _, _} = OptionParser.parse args, switches: [quiet: :boolean]

    Enum.each repos, fn repo ->
      ensure_repo(repo, args)
      ensure_implements(repo.__adapter__, Ecto.Adapter.Storage,
                                          "to create storage for #{inspect repo}")
      case Ecto.Storage.up(repo) do
        :ok ->
          unless opts[:quiet] do
            Mix.shell.info "The database for #{inspect repo} has been created."
          end
        {:error, :already_up} ->
          unless opts[:quiet] do
            Mix.shell.info "The database for #{inspect repo} has already been created."
          end
        {:error, term} when is_binary(term) ->
          Mix.raise "The database for #{inspect repo} couldn't be created, reason given: #{term}."
        {:error, term} ->
          Mix.raise "The database for #{inspect repo} couldn't be created, reason given: #{inspect term}."
      end
    end
  end
end
