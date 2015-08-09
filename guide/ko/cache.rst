서버측 캐시
========

:doc:`클러스터링 </cluster>` 챕터를 참고하세요

Xitrum은 빠른 응답을 위해, 클라이언트 측과 서버 측의 광범위한 캐싱 기능을 제공합니다.
웹서버 레이어는 작은 파일은 메모리에 캐시 된 큰 파일은 NIO의 제로 복사를 사용하여 전송됩니다.
Xitrum 정적 파일 전송 속도는`Nginx와 동등 <https://gist.github.com/3293596>`_ 합니다
Web 프레임 워크 레이어는 Rails 스타일로 페이지 나 액션 객체를 캐시 할 수 있습니다.
`All Google 's best practices (영문) <http://code.google.com/speed/page-speed/docs/rules_intro.html>`_
에서와 같이 조건부 GET 요청은 클라이언트 사이드에서 캐시됩니다.

동적 콘텐츠에 대해서는 만약 파일이 생성 된 이후 변경되지 않는 경우(static file과 같이) 클라이언트에 적극적으로 캐시하도록
헤더를 설정해야합니다.
이 경우에는``setClientCacheAggressively ()``를 액션에서 호출하여 얻을 수 있습니다.

클라이언트에 캐시시키고 싶지 않은 경우에는, ``setNoClientCache ()``를 액션에서 호출하여 얻을 수 있습니다.

서버 측 캐시에 대해서는 다음 예제에 자세히 설명합니다.

캐시페이지 혹은 액션
---------------

::

  import xitrum.Action
  import xitrum.annotation.{GET, CacheActionMinute, CachePageMinute}

  @GET("articles")
  @CachePageMinute(1)
  class ArticlesIndex extends Action {
    def execute() {
      ...
    }
  }

  @GET("articles/:id")
  @CacheActionMinute(1)
  class ArticlesShow extends Action {
    def execute() {
      ...
    }
  }

"page cache"와 "acation cache" 개념은 `Ruby on Rails <http://guides.rubyonrails.org/caching_with_rails.html>`_를 참고하고 있습니다.

요청 처리 프로세스의 순서는 다음과 같습니다.

(1) 요청 -> (2) Before 필터 -> (3) 액션의 excute 메소드 -> (4) 응답

처음 요청시 Xitrum는 응답을 지정된 기간 동안 캐시합니다.
``@CachePageMinute (1)``과``@CacheActionMinute (1)`` 은 1 분 동안 캐시하는 것을 의미합니다.
Xitrum는 응답 상태가 "200 OK"인 경우에만 캐시합니다.
예를들어, 응답 상태가 "500 Internal Server Error"또는 "302 Found"(리디렉션)이되는 응답은 캐시되지 않습니다.

동일한 작업에 대한 동일 요청에는 만약 캐시 된 응답이 지정된 기간내에 있을 경우
Xitrum은 즉시 캐시 된 응답을 반환합니다 :

* 페이지 캐시의 경우 처리 과정은 (1) -> (4)입니다.
* 액션 캐시의 경우 (1) -> (2) -> (4) 또는 Before 필터가 "false"를 반환 한 경우 (1) -> (2)입니다.

차이점은: page 캐시는 Before 필터를 수행하지 않습니다.

일반적으로 페이지 캐시는 모든 사용자에게 공통된 반응의 경우에 사용합니다.
액션 캐시는 Before 필터를 통해 예를 들어 사용자의 로그인 상태 체크 등을 통해 캐시 된 응답을 "가드" 하는 경우에 사용합니다 :

* 로그인 한 경우 캐시 된 응답에 액세스 할 수 있습니다.
* 로그인하지 않은 경우 로그인 페이지로 리다이렉트 합니다.

캐시 오브젝트
----------
 
`xitrum.Cache <http://xitrum-framework.github.io/api/3.17/index.html#xitrum.Cache>`_ 을 대신하여
``xitrum.Config.xitrum.cache`` 사용할 수 있습니다.

명시적으로 TTL을 설정하지 않은 경우:

* put(key, value)

유효기간을 설정한 경우:

* putSecond(key, value, seconds)
* putMinute(key, value, minutes)
* putHour(key, value, hours)
* putDay(key, value, days)

존재하지 않을 경우만 캐시하는 방법:

* putIfAbsent(key, value)
* putIfAbsentSecond(key, value, seconds)
* putIfAbsentMinute(key, value, minutes)
* putIfAbsentHour(key, value, hours)
* putIfAbsentDay(key, value, days)

캐시 제거
-------

페이지나 액션의 캐시 제거:

::

  removeAction[MyAction]

오브젝트 캐시 제거:

::

  remove(key)

prefix로 시작되는 키들을 모두 제거:

::

  removePrefix(keyPrefix)

``removePrefix``는 prefix를 사용하여 계층적 캐쉬를 구축 할 수 있습니다.
예를 들면, 기사와 관련된 요소를 캐쉬하고 싶은 경우, 기사가 변경되었을 때 관련 캐쉬는 다음과 같이 정리할 수 있습니다.

::

  import xitrum.Config.xitrum.cache

  // prefix를 이용하여 캐쉬
  val prefix = "articles/" + article.id
  cache.put(prefix + "/likes", likes)
  cache.put(prefix + "/comments", comments)

  // 필요시, 기사와 관련된 캐쉬를 전부 삭제할 수 있습니다.
  cache.remove(prefix)

설정
---

Xitrum 캐시 기능은 캐시 엔진에 의해 제공됩니다. 캐시 엔진은 프로젝트의 필요에 따라 취사선택할 수 있습니다.
캐시 엔진 설정은 `config / xitrum.conf <https://github.com/xitrum-framework/xitrum-new/blob/master/config/xitrum.conf>`_에서 사용하는 엔진에 따라 다음 두 가지 설명 방식으로 설정할 수 있습니다.

::

  cache = my.cache.EngineClassName

또는:

::

  cache {
    "my.cache.EngineClassName" {
      option1 = value1
      option2 = value2
    }
  }

Xitrum은 이것을 제공합니다:

::

  cache {
    # Simple in-memory cache
    "xitrum.local.LruCache" {
      maxElems = 10000
    }
  }

만약 클러스터링 된 서버를 사용하는 경우 캐쉬 엔진에는`Hazelcast <https://github.com/xitrum-framework/xitrum-hazelcast>`_를 사용할 수 있습니다.

자체 캐쉬 엔진을 사용하는 경우,``xitrum.Cache``의`interface <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/Cache.scala> `_를 구현합니다.

캐쉬의 동작원리
-----------

Inbound:

::

                 액션응답
                 캐쉬됨
  request        캐쉬가 존재?
  -------------------------+---------------NO--------------->
                           |
  <---------YES------------+
    캐쉬에서 응답

Outbound:

::

                 액션응답
                 캐쉬됨
                 캐쉬가 존재하지 않음? 　          response
  <---------NO-------------+---------------------------------
                           |
  <---------YES------------+
    캐쉬를 저장함

xitrum.util.LocalLruCache
-------------------------

위에서 언급 한 캐쉬 엔진은 시스템 전체가 공유하는 캐시입니다.
만약 작은 간단한 캐쉬 엔진 만 필요한 경우``xitrum.util.LocalLruCache``을 사용합니다.

::

  import xitrum.util.LocalLruCache

  // LRU (Least Recently Used) 캐쉬는 1000개만 저장합니다
  // 키와 저장값은 String 타입으로 사용됩니다
  val cache = LocalLruCache[String, String](1000)

반환된 ``캐쉬`` 는 `java.util.LinkedHashMap <http://docs.oracle.com/javase/6/docs/api/java/util/LinkedHashMap.html>`_ 인스턴스이기 때문에 ``LinkedHashMap`` 방법을 사용하여 처리 할 수 있습니다.
