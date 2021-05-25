class HelloTeam
    # Call method that would return the HTTP status code, the content type and the content.
    def call (env)
      return ["200 OK", {"Content-Type" => "text/html"}, ["Hello, TEAM!"]]
    end
  end 