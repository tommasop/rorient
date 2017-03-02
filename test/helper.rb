require "uri"
require "rorient"
require "minitest/autorun"
require "purdytest"

#Dir['./test/support/**/*.rb'].each do |file|
#    require file
#end

class Testing
  SERVER = ENV['SERVER'] || "http://159.122.132.173:2480"
  USERNAME  = ENV['USERNAME']  || "root"
  PASSWORD  = ENV['PASSWORD']  || "Makeplan$2015"
  DATABASE   = ENV['DATABASE']  || "pev_fenice"
end

ODB = Rorient::Client.new(server: Testing::SERVER, user: Testing::USERNAME, password: Testing::PASSWORD, scope: { database: Testing::DATABASE })

# class IntegrationMap < Rorient::Vertex(ODB); end
class Drawing < Rorient::Vertex(ODB); end
class DrawingLayers < Rorient::Edge(ODB); end
class Layer < Rorient::Vertex(ODB); end
class LayerEntities < Rorient::Edge(ODB); end
class Entity < Rorient::Vertex(ODB); end
# class IntegrationDrawing < Rorient::Edge(ODB); end



