module Rorient
  class CommandResource < ResourceKit::Resource
    include ErrorHandlingResourceable

    resources do
      action :execute do
        path { "/command/#{database}/sql/:command_text" }
        verb :post
        handler(200) { |response| Oj.load(response.body) }
      end
    end

    def database
      scope[:database]
    end
  end
end
