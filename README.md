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


