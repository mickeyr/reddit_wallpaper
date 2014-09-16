defmodule RedditWallpaper.RedditPosts do
  require Logger
  @user_agent [{"User-agent", "Elixir wallpaper fetcher"}]
  @wallpaper_url Application.get_env(:RedditWallpaper, :wallpaper_url)
  
  def fetch(queue) do
    wallpaper_queue_url(queue)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end
  
  def wallpaper_queue_url(queue) do
    Logger.info "Url: " <> "#{@wallpaper_url}/#{queue}.json"
    "#{@wallpaper_url}/#{queue}.json"
  end
  
  def handle_response(%{status_code: 200, body: body}), do: {:ok, :jsx.decode(body)}
  def handle_response(%{status_code: ___, body: body}), do: {:error, body}
    
end  