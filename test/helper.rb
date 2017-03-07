require "uri"
require "rorient"
require "minitest/autorun"
require "purdytest"

#Dir['./test/support/**/*.rb'].each do |file|
#    require file
#end

class Testing
  SERVER = ENV['DATABASE_URL'] 
  USERNAME  = ENV['DATABASE_USER']
  PASSWORD  = ENV['DATABASE_PASSWORD']
  DATABASE   = ENV['DATABASE_NAME']
end

ODB = Rorient::Client.new(server: Testing::SERVER, user: Testing::USERNAME, password: Testing::PASSWORD, scope: { database: Testing::DATABASE })

class IntegrationMap < Rorient::Vertex(ODB); end
class Drawing < Rorient::Vertex(ODB)
  named_vertexes :layers, "DrawingLayers", :out
end
class DrawingLayers < Rorient::Edge(ODB); end
class Layer < Rorient::Vertex(ODB); end
class LayerEntities < Rorient::Edge(ODB); end
class Entity < Rorient::Vertex(ODB); end
class IntegrationDrawing < Rorient::Edge(ODB); end



