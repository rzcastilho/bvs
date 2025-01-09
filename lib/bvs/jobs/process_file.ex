defmodule BVS.Jobs.ProcessFile do
  use Oban.Worker

  require Logger

  alias BVS.{
    Negativation,
    Parser
  }

  def perform(%Oban.Job{args: %{"id" => id, "file" => file} = args}) do
    Logger.info("Starting job #{__MODULE__}...\n  -> #{inspect(args)}")

    %{id: success_id} = Negativation.get_return_code_by_code("00")

    success =
      file
      |> Parser.parse()
      |> Enum.map(&Map.put(&1, :return_file_id, id))
      |> Enum.map(&Negativation.create_item/1)
      |> Enum.all?(&success_item?(&1, success_id))

    status = if success, do: :reviewed, else: :pending

    {:ok, _return_file} = Negativation.update_return_file_status_by_id(id, status)

    Logger.info("Job #{__MODULE__} done!")
  end

  def success_item?({:ok, %{return_code_id: id}}, id), do: true

  def success_item?(_item, _id), do: false
end
