  UP_STATEMENTS = { transaction: false,
                       operations: [
                         {
                           type: "script",
                           language: "sql",
                           script: [ 
                                     "CREATE CLASS Planimetry",
                                     "CREATE PROPERTY Planimetry.name STRING",
                                     "CREATE PROPERTY Planimetry.unit STRING",
                                     "CREATE PROPERTY Planimetry.gis_point_lat DOUBLE",
                                     "CREATE PROPERTY Planimetry.gis_point_long DOUBLE",
                                     "CREATE PROPERTY Planimetry.current_layer STRING"
                           ]
                         }
                       ]
                     }

    DOWN_STATEMENTS = { transaction: false,
                       operations: [
                         {
                           type: "script",
                           language: "sql",
                           script: [ 
                                     "DROP CLASS Planimetry"
                           ]
                         }
                       ]
                     }

    
