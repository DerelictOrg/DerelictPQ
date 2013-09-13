DerelictPQ
==========

A dynamic binding to the [http://www.postgresql.org/docs/current/static/libpq.html](libpq) library version 9.3 for the D Programming Language.

For information on how to build DerelictPQ and link it with your programs, please see the post [Building and Using Packages in DerelictOrg](http://dblog.aldacron.net/forum/index.php?topic=841.0) at the Derelict forums.

For information on how to load the libpq library via DerelictPQ, see the page [DerelictUtil for Users](https://github.com/DerelictOrg/DerelictUtil/wiki/DerelictUtil-for-Users) at the DerelictUtil Wiki. In the meantime, here's some sample code.

```D
import derelict.pq.pq;

void main() {
    // Load the PhysicsFS library.
    DerelictPQ.load();

    // Now libpq functions can be called.
    ...
}
```