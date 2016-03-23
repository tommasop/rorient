module Rorient
  class BatchResource < ResourceKit::Resource
    include ErrorHandlingResourceable

    resources do
      action :execute do
        path { "/batch/#{database}/" }
        verb :post
        body { |object| Oj.dump(object, mode: :compat) }
        handler(200) { |response| Oj.load(response.body) }
      end
    end

    def database
      scope[:database]
    end
  end
end
