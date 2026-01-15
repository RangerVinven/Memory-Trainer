Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "localhost:1234", "127.0.0.1:1234"

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
