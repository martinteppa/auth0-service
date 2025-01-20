class JsonErrorHandler
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      @app.call(env)
    rescue StandardError => e
      # Devuelve una respuesta JSON con el stacktrace
      [
        500,
        { 'Content-Type' => 'application/json' },
        [
          {
            error: e.message,
            backtrace: e.backtrace.take(30)
          }.to_json
        ]
      ]
    end
  end
end