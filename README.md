DerelictPQ
==========

A dynamic binding to the [libpq][1] library, versions 9.3 and 9.4, for the D Programming Language.

Please see the [Derelict documentation][2] for information on how to build DerelictPQ and load libpq at run time. In the meantime, here's some sample code.

```D
import derelict.pq.pq;

void main() {
    // Load the Postgres library.
    DerelictPQ.load();

    // Now libpq functions can be called.
    ...
}
```

[1]: http://www.postgresql.org/docs/9.3/static/libpq.html
[2]: https://derelictorg.github.io/
