Clustering with Hazelcast
=========================

Xitrum is designed in mind to run in production environment as multiple instances
behind a proxy server or load balancer:

::

                                / Xitrum instance 1
  Load balancer/proxy server ---- Xitrum instance 2
                                \ Xitrum instance 3

Cache and Comet are clustered out of the box thanks to `Hazelcast <http://www.hazelcast.com/>`_.
Please see ``hazelcastMode`` in ``config/xitrum.conf``, ``config/hazelcast_cluster_or_lite_member.xml``,
``config/hazelcast_java_client.properties``, and read `Hazelcast's documentation <http://www.hazelcast.com/docs/2.4/manual/single_html/#Config>`_
to know how to config.

Session are stored in cookie by default. You don't need to worry how to share
sessions among Xitrum instances. But if you use :doc:`HazelcastSessionStore </scopes>`,
you may need to setup session replication by setting ``backup-count`` at the map
``xitrum/session`` in config/hazelcast_cluster_or_lite_member.xml to more than 0.

xitrum.Config.hazelcastInstance
-------------------------------

Xitrum includes Hazelcast for cache and Comet. Thus, you can also use Hazelcast
in your Xitrum project yourself.

Hazelcast has `3 modes <http://www.hazelcast.com/docs/2.4/manual/multi_html/ch07s03.html>`_:
cluster member, lite member, and Java client. Please see ``hazelcastMode``
in ``config/xitrum.conf``. Xitrum handles these modes automatically.

To craete a `Hazelcast map <http://www.hazelcast.com/docs/2.4/manual/multi_html/ch02s03.html>`_:

::

  import com.hazelcast.core.IMap
  import xitrum.Config
  val myMap = Config.hazelcastInstance.getMap("myMap").asInstanceOf[IMap[MyKeyType, MyValueType]]

To create a `Hazelcast topic <http://www.hazelcast.com/docs/2.4/manual/multi_html/ch02s02.html>`_:

::

  import xitrum.Config
  val myTopic = Config.hazelcastInstance.getTopic[MyTopicEventType]("myTopicName")
