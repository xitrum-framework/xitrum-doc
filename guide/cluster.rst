Clustering with Akka and Hazelcast
==================================

Xitrum is designed in mind to run in production environment as multiple instances
behind a proxy server or load balancer:

::

                                / Xitrum instance 1
  Load balancer/proxy server ---- Xitrum instance 2
                                \ Xitrum instance 3

SockJS sessions and `many data structures <http://www.hazelcast.com/docs/2.5/manual/multi_html/ch02.html>`_
are clustered out of the box thanks to `Akka <http://akka.io/>`_ and `Hazelcast <http://www.hazelcast.com/>`_.

Please see ``remote`` in ``config/akka.conf`` and ``hazelcastMode`` in ``config/xitrum.conf``,
and read `Akka doc <http://doc.akka.io/docs/akka/2.1.0/scala/remoting.html>`_ and
`Hazelcast's doc <http://www.hazelcast.com/docs/2.5/manual/single_html/#Config>`_
to know how to config.

Session are stored in cookie by default. You don't need to worry how to share
sessions among Xitrum instances. But if you use :doc:`HazelcastSessionStore </scopes>`,
you may need to setup session replication by setting ``backup-count`` at the map
``xitrum/session`` in config/hazelcast_cluster_or_lite_member.xml to more than 0.

xitrum.Config.hazelcastInstance
-------------------------------

Xitrum includes Hazelcast. You can also use Hazelcast in your Xitrum project.

To create a `distributed map <http://www.hazelcast.com/docs/2.5/manual/multi_html/ch02s03.html>`_:

::

  import com.hazelcast.core.IMap
  import xitrum.Config
  val myMap = Config.hazelcastInstance.getMap("myMap").asInstanceOf[IMap[MyKeyType, MyValueType]]

To create a `distributed topic <http://www.hazelcast.com/docs/2.5/manual/multi_html/ch02s02.html>`_:

::

  import xitrum.Config
  val myTopic = Config.hazelcastInstance.getTopic[MyTopicEventType]("myTopicName")
