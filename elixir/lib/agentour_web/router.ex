defmodule AgentourWeb.Router do
  use AgentourWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AgentourWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug AgentourWeb.AuthPlug, :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :require_authenticated_user do
    plug AgentourWeb.AuthPlug, :ensure_authenticated
  end

  scope "/", AgentourWeb do
    pipe_through :browser

    live "/register", Auth.RegisterLive
    post "/register", AuthController, :register
    live "/login", Auth.LoginLive
    post "/auth/login", AuthController, :login
    get "/auth/logout", AuthController, :logout
  end

  scope "/", AgentourWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :authenticated, on_mount: {AgentourWeb.InitAssigns, :current_user} do
      live "/", SessionLive.Index, :index
      live "/profile", ProfileLive
      live "/sessions", SessionLive.Index, :index
      live "/sessions/new", SessionLive.New, :new
      live "/sessions/:id", SessionLive.Show, :show
      live "/sessions/:id/edit", SessionLive.Edit, :edit
      live "/agents", AgentLive.Index
      live "/agents/new", AgentLive.New
      live "/agents/:id", AgentLive.Show
      live "/agents/:id/edit", AgentLive.Edit
      live "/artifacts/:id", ArtifactLive.Show
      live "/artifacts/:id/edit", ArtifactLive.Edit
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", AgentourWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:agentour, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AgentourWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
