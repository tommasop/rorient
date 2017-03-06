# Rorient

Rorient is a ruby gem thought as a lightweight Graph ORM on top of OrientDB HTTP API.

It has:

- Migrations (loosely based on sql_migrations)
- ActiveRecord like methods (loosely based on OHM)
- Easy graph traversal methods
- Sequel like db instantiation and model data declaration

It is being actively developed thanks to [Makeplan](http://www.makeplan.it) 

A simple Rorient connection is like this:

```
ODB = Rorient.connect(server: '123.144.122.444:2480', user: 'myuser', password: 'mypassword', db_name: 'mydb')
```

Then you can have vertexes or edges inheriting from `Rorient::Base` this way:

```
class User < Rorient::Vertex(ODB)
end

class Car < Rorient::Vertex(ODB)
end

class Has < Rorient::Edge(ODB)
end

```

Graph relations can be defined with helpers:

```
# One model OUT graph relation
named_vertexes :cars, "Has", :out
# Another model IN graph relation
named_vertexes :owner, "Has", :in
```

About migrations you can have the usual `db/migrations` directory but need
to use **sql** files with this timestamp naming convention:

`YYYYMMGG_HHmmss_migration_name.sql`

In the migration file you need to use `--migration;`and `--end-migration;`and `--rollback;`and `--end-rollback;`
tags like this:

```
--migration;
CREATE CLASS Planimetry EXTENDS V;
CREATE PROPERTY Planimetry.name STRING;
CREATE PROPERTY Planimetry.unit STRING;
--end-migration;
--rollback;
DROP Planimetry UNSAFE;
--end-rollback;
```

Then use the familiar `rorient:db:migrate` and `rorient:db:rollback`rake tasks.

For the rollback you can also pass a `STEPS` env variable to the task to specify
how many migrations must be rolled back.

```
   rake rorient:db:rollback STEPS=3
```

## Directed Graph relations

Graph relations are simply direct links between objects this means you could have multiple
links between the same objects.
If you need to enforce the graph direction in the classic relationship has_many/belongs_to
fashion you need to manually define it in the edge creation like this:

```
--migration;
CREATE CLASS OrientedConnection EXTENDS E;
CREATE PROPERTY OrientedConnection.out LINK;
CREATE PROPERTY OrientedConnection.in LINK;
ALTER PROPERTY OrientedConnection.out MANDATORY=true;
ALTER PROPERTY OrientedConnection.in MANDATORY=true;
CREATE INDEX UniqueOrientedConnection ON OrientedConnection(out,in) UNIQUE;
--end-migration;
--rolback;
DROP CLASS OrientedConnection UNSAFE;
--end-rollback;
```

## ONE2MANY, ONE2ONE, MANY2ONE relations

Apart from graph direction you can also force the relationship between graph nodes
to mimick relational ones.

If we conventionally say that FROM = out and TO = in then we can shape a:

1. ONE2MANY --> CREATE INDEX MyEdgeClass.in ON MyEdgeClass(in) UNIQUE
2. MANY2ONE --> CREATE INDEX MyEdgeClass.out ON MyEdgeClass(out) UNIQUE
3. ONE2ONE --> CREATE INDEX MyEdgeClass.out ON MyEdgeClass(out) UNIQUE; CREATE INDEX MyEdgeClass.in ON MyEdgeClass(in) UNIQUE

## Graph traversal methods

The library has methods that mimicks the OrientDB graph query methods.

### Vertexes

```
u = User.first

u.out.to_a # returns all out vertexes from user
u.in.to_a # returns all in vertexes from user
u.both.to_a # returns all in and out vertexes from user
u.outE.to_a # returns all out edges from user
u.inE.to_a # returns all in edges from user
u.bothE.to_a # returns all in and out edges from user
u.traverseO.to_a # returns all the out vertexes in the graph starting from node u
u.traverseI.to_a # returns all the in vertexes in the graph starting from node u
```

Each method can be given one or more edge classes as a filter for the nodes to be retrieved

```
u.out("Has").to_a # returns all Has out vertexes from user
u.out(["Has", "Friends"]).to_a
```

Specifying the traversal edges results in a performance boost.

The traverse methods can receive two other arguments:

1. depth: sets the maximum traversal depth (default is all the graph)
2. strategy: sets the strategy (default is DEPTH_FIRST, can be changed to BREADTH_FIRST)

```
u.traverseO("Has", 2, "BREADTH_FIRST")
```

### Edges

```
h = Has.first

h.outV("Car").to_a
h.inV("User").to_a
h.bothV.to_a
```
