module Rorient
  class OPropertyResource < ResourceKit::Resource
    include ErrorHandlingResourceable

    resources do
      action :create do
        path { "/property/#{database}/:class_name" }
        verb :post
        body { |object| Oj.dump(object, mode: :compat) }
        handler(201) { |response|  response.body }
        # handler(422) { |response| ErrorMapping.fail_with(FailedCreate, response.body) }
      end
    end

    def database
      scope[:database]
    end
  end
end
