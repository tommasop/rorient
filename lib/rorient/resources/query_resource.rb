module Rorient
  class QueryResource < ResourceKit::Resource
    include ErrorHandlingResourceable

    resources do
      action :execute do
        path { "/query/#{database}/sql/:query_text" }
        verb :get
        handler(200) { |response| Oj.load(response.body) }
      end
    end

    def database
      scope[:database]
    end
  end
end
