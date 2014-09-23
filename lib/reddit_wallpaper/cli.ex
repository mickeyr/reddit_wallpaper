defmodule RedditWallpaper.CLI do
  require Logger
  @moduledoc """
    Handles the command line arguments and the dispatch to 
    the various functions to end up downloading a random
    wallpaper from reddit's /r/wallpapers
  """
  def main(argv) do
    argv
    |> parse_args
    |> process
  end
  
  @doc """
    `argv` can be -h or --help, which returns :help.

    Otherwise it is the queue to download the random wallpaper
    from.  Valid entries are 'hot', 'new', 'rising', 
    'controversial', 'top', and 'gilded'
  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean],
                                     alieases: [h: :help])

    case parse do
      { [help: true], _ } -> :help
      { _, queue, _ } -> queue
      _ -> "hot"
    end
  end
  
  @doc """
    Displays the usage syntax for this command.
  """
  def process(:help) do
    IO.puts """
      usage: wallpaper <queue>
    """
    System.halt(0)
  end

  @doc """
    Processes the request to download a ranomd wallpaper
    from the entered queue
  """
  def process(queue) do
    RedditWallpaper.RedditPosts.fetch(queue)
    |> decode_response
    |> get_urls
    |> Enum.filter(&(String.ends_with? &1, "jpg"))
    |> Enum.shuffle
    |> Enum.take(1)
    |> download_image
  end

  def decode_response({:ok, body}), do: body
  def decode_response({:error, error}) do
    IO.puts "Error fetching a wallpaper from reddit: #{error}"
    System.halt(2)
  end
  
  def get_urls(response) do
    response["data"]["children"]
    |> Enum.map &(&1["data"]["url"])
  end

  def is_link_to_image(url) do
    
  end

  def get_random_url(posts) do
    posts
    |> Enum.flat_map(&get_urls/1)
    |> Enum.shuffle
    |> Enum.take(1)
  end

  def download_image([image]) do
    Logger.info "Downloading " <> image
    image
    |> HTTPoison.get
    |> handle_response
  end

  def handle_response(%{status_code: 200, body: body}) do
    File.write!("wallpaper.jpg", body)
  end
  def handle_response(%{status_code: ___, body: body}), do: {:error, body}
end
