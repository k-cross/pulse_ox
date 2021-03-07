defmodule PulseOxPlatformWeb.Router do
  use PulseOxPlatformWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PulseOxPlatformWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PulseOxPlatformWeb do
    pipe_through :browser

    live "/", PageLive, :index
  end
end
