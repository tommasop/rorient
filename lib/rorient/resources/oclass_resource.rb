module Rorient
  class OClassResource < ResourceKit::Resource
    include ErrorHandlingResourceable

    resources do
      action :find do
        path { "/class/#{database}/:class_name" }
        verb :get
        handler(200) { |response| Oj.load(response.body) }
        #handler(401) { |response| puts response.body }
        handler(404) { |response| nil }
      end

      action :create do
        path { "/class/#{database}/:class_name" }
        verb :post
        # body { |object| Oj.dump(object, mode: :compat) }
        handler(201) { |response|  response.body }
        #handler(401) { |response| puts response.body }
        # handler(422) { |response| ErrorMapping.fail_with(FailedCreate, response.body) }
      end

      #action :update do
      #  path { "/document/#{database}/:rid" }
      #  verb :patch
      #  body { |object| Oj.dump(object, mode: :compat) }
      #  handler(200) { |response|  response.body }
      #  # handler(422) { |response| ErrorMapping.fail_with(FailedCreate, response.body) }
      #end

      action :delete do
        path { "/class/#{database}/:class_name" }
        verb :delete
        handler(204) { |response| true }
        #handler(401) { |response| puts response.body }
      end

      #action :actions, 'GET /document/:id/actions' do
      #  query_keys :per_page, :page
      #  handler(200) { |response| ActionMapping.extract_collection(response.body, :read) }
      #end
    end

    def database
      scope[:database]
    end
  end
end
