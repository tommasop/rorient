module Rorient
  class DocumentResource < ResourceKit::Resource
    include ErrorHandlingResourceable

    resources do
      action :find do
        path { "/document/#{database}/:rid" }
        verb :get
        handler(200) { |response| Oj.load(response.body) }
      end
      
      action :exists do
        path { "/document/#{database}/:rid" }
        verb :head
        handler(204) { |response| true }
        handler(404) { |response| false }
      end

      action :create do
        path { "/document/#{database}/" }
        verb :post
        body { |object| Oj.dump(object, mode: :compat) }
        handler(201) { |response|  Oj.load(response.body) }
        # handler(422) { |response| ErrorMapping.fail_with(FailedCreate, response.body) }
      end

      action :update do
        path { "/document/#{database}/:rid" }
        verb :patch
        body { |object| Oj.dump(object, mode: :compat) }
        handler(200) { |response|  Oj.load(response.body) }
        # handler(422) { |response| ErrorMapping.fail_with(FailedCreate, response.body) }
      end

      action :delete do
        path { "/document/#{database}/:rid" }
        verb :delete
        handler(204) { |response| true }
      end
    end

    def database
      scope[:database]
    end
  end
end
