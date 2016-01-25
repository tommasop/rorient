class Urbobj < Rorient::Model
  set_database "ff423"
  set_client
  define_attributes

  outs "has_props", "UrbobjProp"
  ins "has_orders", "JobOrder"
end
