DerelictPQ
==========

A dynamic binding to the [libpq][1] library version 9.3 for the D Programming Language.

For information on how to build DerelictPQ and link it with your programs, please see the post [Using Derelict][2] at The One With D.

For information on how to load the libpq library via DerelictPQ, see the page [DerelictUtil for Users][3] at the DerelictUtil Wiki. In the meantime, here's some sample code.

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
[2]: http://dblog.aldacron.net/derelict-help/using-derelict/
[3]: https://github.com/DerelictOrg/DerelictUtil/wiki/DerelictUtil-for-Users
