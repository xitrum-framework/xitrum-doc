Akka와 Hazelcast 클러스터링
=============================================

Xitrum가 프록시 서버와 로드 밸런서 뒤에 클러스터 구성에서 동작할 수 있도록 설계되어 있습니다.

::

                           / Xitrum 인스턴스 1
  로드밸런서/프록시 서버      ---- Xitrum 인스턴스 2
                           \ Xitrum 인스턴스 3

`Akka <http://akka.io/>`_ 와 `Hazelcast <https://github.com/xitrum-framework/xitrum-hazelcast>`_
클러스터링 기능을 사용하여 캐시, 세션, SockJS세션을 클러스터링 할 수 있습니다.

Hazelcast가 Xitrum 인스턴스의 프로세스의 메모리 캐시 서버가 되므로
Memcache 같은 추가 서버는 필요하지 않습니다.

Akka와 Hazelcast 클러스터링을 설정하려면 ``config / akka.conf`` `Akka 문서 <http://akka.io/docs/>`_
`Hazelcast 문서 <http://hazelcast.org/documentation/>`_ 를 참고하십시오.

참고 : 세션, :doc:`클라이언트 측 쿠키에 저장 </ scopes>` 할 수 있습니다.
