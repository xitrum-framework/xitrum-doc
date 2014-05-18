Clustering with Akka and Hazelcast
==================================

Xitrum is designed in mind to run in production environment as multiple instances
behind a proxy server or load balancer:

::

                                / Xitrum instance 1
  Load balancer/proxy server ---- Xitrum instance 2
                                \ Xitrum instance 3

Cache, sessions, and SockJS sessions can be clustered out of the box thanks to
`Akka <http://akka.io/>`_ and `Hazelcast <https://github.com/xitrum-framework/xitrum-hazelcast>`_.

With Hazelcast, Xitrum instances become in-process memory cache servers. You don't
need seperate things like Memcache.

Please see ``config/akka.conf``, and read `Akka doc <http://akka.io/docs/>`_ and
`Hazelcast doc <http://hazelcast.org/documentation/>`_ to know how to config Akka and
Hazelcast clustering.

Note: For sessions, you can also :doc:`store them at client side in cookie </scopes>`.
