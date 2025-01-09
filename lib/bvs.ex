defmodule BVS do
  use DoIt.MainCommand,
    description: "BVS CLI"

  command(BVS.Commands.Server)
end
