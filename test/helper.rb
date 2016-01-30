require "cutest"
require_relative "../lib/rorient"

class Cutest::Scope

  def assert_redirected_to(path)
    unless last_response.status == 302
      flunk
    end
    assert_equal path, URI(redirection_url).path
  end

  def redirection_url
    last_response.headers["Location"]
  end

  def session
    last_request.env["rack.session"]
  end
end
