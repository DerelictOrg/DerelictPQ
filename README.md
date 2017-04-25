DerelictPQ
==========

A dynamic binding to the [libpq][1] library version 9.6 for the D Programming Language.

Please see the sections on [Compiling and Linking][2] and [The Derelict Loader][3] in the Derelict documentation for information on how to build DerelictPQ and load libpq at run time. In the meantime, here's some sample code.

```D
import derelict.pq.pq;

void main() {
    // Load the Postgres library.
    DerelictPQ.load();

    // Now libpq functions can be called.
    ...
}
```

[1]: http://www.postgresql.org/docs/9.6/static/libpq.html
[2]: http://derelictorg.github.io/building/overview/
[3]: http://derelictorg.github.io/loading/loader/
