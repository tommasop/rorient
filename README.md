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
User.out.to_a # returns all out vertexes from User
User.in.to_a # returns all in vertexes from User
User.both.to_a # returns all in and out vertexes from User
User.outE.to_a # returns all out edges from User
User.inE.to_a # returns all in edges from User

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
u.out("Has", "Friends").to_a
```

Each edge class can be given one or more fields on which to filter

```
User.out("Has" => {name: "George", surname: "White"}).to_a 
u.out("Has" => {name: "George", surname: "White"}).to_a 
User.out("Has" => {name: "George", surname: "White"}, "Friends" => {job: "doctor"}).to_a 
u.out("Has" => {name: "George", surname: "White"}, "Friends" => {job: "doctor"}).to_a 
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

## Query

### Ohm style models

Rorient models are loosely based on [Ohm](https://github.com/soveran/ohm).

All models have the rid attribute built in, you don't need to declare it.

This is how you interact with RIDs:

```ruby
event = Event.create :name => "Rorient Worldwide Conference 2031"
event.rid
# => 25:1

# Find an event by rid
event == Event['25:1']
# => true

# Update an event
event.update :name => "Ohm Worldwide Conference 2032"
# => #<Event:0x007fb4c35e2458 @attributes={:name=>"Ohm Worldwide Conference"}, @_memo={}, @rid="1">

# Trying to find a non existent event
Event['25:32']
# => nil

# Finding all the events
Event.all.to_a

# See if a specific event exists
Event.exists?('25:1")
# => true

# Delete an event
event.delete

# Delete an array of events
Event.delete(['25:1', '25:2', '25:3'])
```

### Rorient Query DSL

Rorient implements `SELECT, SELECT EXPAND and MATCH` queries as defined in [OrientDB SQL dialect](https://orientdb.com/docs/2.2/SQL.html).
It also implements OrientDB `WHERE` syntax. 

```ruby
  select_query = Rorient::Query.select(odb)
  select_expand_query = Rorient::Query.select_expand(odb)
  match_query = Rorient::Query.match(odb)

  # Models have a query method that initializes by default a select expand query
  Event.query
  # But the query method accepts a parameter that can change the query type
  # valid parameter values are: select, select_expand, match
  Event.query("match")
```

Simple `SELECT` query:

```ruby
  query = Rorient::Query.select(odb).from(Event)

  # To know the actual OrientDB SQL produced you can use the .osql method
  query.osql
  # => SELECT FROM Drawing /-1
  # NOTE: OrientDB SQL doesn't need * but as we are accessing the HTTP API
  # we need the /-1 to let the API know we want all the data back and not
  # only the first 20 records
```

The `FROM` clause can either be a Rorient Model or an array od RIDs.
The `FROM` clause can also be a **subquery** through the `subquery` method
The subquery must be initialized and afterwards it can be treated as a normal
query method.

```ruby
  query = Rorient::Query.select(odb).from('25:1', '25:2', '25:3')
  query_from_select = Rorient::Query.select(odb).subquery
  query_from_select.subquery.from(Entity){ name('Rorient Conference') }
  query_from_select.fields("name", "location")
  query_from_select.osql
  # => SELECT name,surname FROM (SELECT FROM Entity WHERE name = 'Rorient Conference') /-1
```

When starting a query from a Rorient model the `FROM` is automatically set to the model name.
To simplify the query building in a Rorient model you can pass a block to the query object that
will be transformed in its `WHERE` clause.

```ruby
  Event.query("select"){ name('Rorient Conference') }
  # The same as
  Event.query("select").where{ name('Rorient Conference') }
```

#### WHERE clause DSL

The `WHERE` clause in Rorient is a separate class using method_missing magic to easily
implement a feature rich set of filtering functions and operators.

The where clause is called with a `block` the methods inside the block can be chained.
The methods are differently interpreted according to their arguments.

A method with no arguments will be passed as is to the where clause:

```ruby
  Event.query("select").where{ coffee_break.is.not.defined }.osql
  # => SELECT FROM Event WHERE coffee_break IS NOT DEFINED
```

A method with one argument implements a classic filtering condition based on equality:

```ruby
  Event.query("select").where{ name("Rorient Conference") }.osql
  # => SELECT FROM Event WHERE name = "Rorient Conference"
```

There are two special single arguments: `nil` and `true` used for `IS NULL` and `IS NOT NULL`

```ruby
  Event.query("select").where{ name(nil) }.osql
  # => SELECT FROM Event WHERE name IS NULL 
  Event.query("select").where{ name(true) }.osql
  # => SELECT FROM Event WHERE name IS NOT NULL
```

Methods with two arguments have the first argument which defines the operator
while the second one the condition:

```ruby
  Event.query("select").where{ name(:like, "Rorient") }.osql
  # => SELECT FROM Event WHERE name LIKE '%Rorient%' 
  Event.query("select").where{ name(:!, "Rorient") }.osql
  # => SELECT FROM Event WHERE name <> "Rorient"
```

Methods with more than two arguments (or two arguments without operators) are used for `IN` clauses:

```ruby
  Event.query("select").where{ name("Rorient Conference","Rails Conference","Ruby Conference") }.osql
  # => SELECT FROM Event WHERE name IN ("Rorient Conference","Rails Conference","Ruby Conference")
```

This simple DSL can be used to have complex conditions:

```ruby
  Event.query("select").where{ name(:!, "Workshop").and.name("Rorient Conference","Rails Conference","Ruby Conference").or.location(:like, 'Hall') }.osql
  # => SELECT FROM Event WHERE name <> "Workshop" AND name IN ("Rorient Conference","Rails Conference","Ruby Conference") OR location LIKE '%Hall%'
```
