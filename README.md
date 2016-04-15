# Rorient

Rorient is a ruby gem thought as a lightweight ORM on top of OrientDB HTTP API.

It has:

- Migrations (loosely based on sql_migrations)
- ActiveRecord like methods (loosely based on OHM)
- Sequel like db instantiation and model data declaration

It is being actively developed thanks to [Makeplan](http://www.makeplan.it) 

A simple Rorient connection is like this:

```
DB = Rorient.connect(server: '123.144.122.444:2480', user: 'myuser', password: 'mypassword', db_name: 'mydb')
```

Then you can have models inheriting from `Rorient::Model` this way:

```
class User < Rorient::Model(DB)
end
```

And graph relations defined with activerecord style:

```
# One model OUT graph relation
has_many "friends", vertex: "User", edge: "connections"
# Another model IN graph relation
belongs_to "friend", vertex: "User", edge: "connections"
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

