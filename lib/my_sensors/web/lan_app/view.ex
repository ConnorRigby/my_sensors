defmodule MySensors.Web.LanApp.View do
  def render(file_name, info \\ []) do
    file_name |> template_file() |> EEx.eval_file(info)
  end

  defp template_file(file) do
    "#{:code.priv_dir(:my_sensors)}/lan_app/templates/#{file}.html.eex"
  end
end
