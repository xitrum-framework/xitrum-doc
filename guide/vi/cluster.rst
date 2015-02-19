Clustering với Akka và Hazelcast
================================

Xitrum được thiết kế để chạy trong môi trường sản xuất như nhiều instance
đằng sau một máy chủ proxy hoặc cân bằng tải:

::

                                / Xitrum instance 1
  Load balancer/proxy server ---- Xitrum instance 2
                                \ Xitrum instance 3

Cache, sessions, và SockJS sessions có thể được be clustered bởi tính năng của
`Akka <http://akka.io/>`_ và `Hazelcast <https://github.com/xitrum-framework/xitrum-hazelcast>`_.

Với Hazelcast, Xitrum trở thành một in-process memory cache server. Bạn không cần
sử dụng các máy chủ bổ sung như Memcache.

Xem thêm ``config/akka.conf``, và đọc `Akka doc <http://akka.io/docs/>`_ hay
`Hazelcast doc <http://hazelcast.org/documentation/>`_ để biết cách cấu hình
Akka và Hazelcast cluster.

Nhớ rằng: Với session, bạn cũng có thể :doc:`lưu trữ ở client bằng cookie /scopes>`.
