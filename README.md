DerelictPQ
==========

A dynamic binding to the [libpq][1] library version 9.3 for the D Programming Language.

Please see the pages [Building and Linking Derelict][2] and [Using Derelict][3], in the Derelict documentation, for information on how to build DerelictPQ and load libpq at run time. In the meantime, here's some sample code.

```D
import derelict.pq.pq;

void main() {
    // Load the Postgres library.
    DerelictPQ.load();

    // Now libpq functions can be called.
    ...
}
```

[1]: http://www.postgresql.org/docs/current/static/libpq.html
[2]: http://derelictorg.github.io/compiling.html
[3]: http://derelictorg.github.io/using.html
