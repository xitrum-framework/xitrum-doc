소개
====

::

  +--------------------+
  |      Clients       |
  +--------------------+
            |
  +--------------------+
  |       Netty        |
  +--------------------+
  |       Xitrum       |
  | +----------------+ |
  | | HTTP(S) Server | |
  | |----------------| |
  | | Web framework  | |  <- Akka, Hazelcast -> Other instances
  | +----------------+ |
  +--------------------+
  |      Your app      |
  +--------------------+

Xitrum은 `Netty <http://netty.io/>`_ 와 `Akka <http://akka.io/>`_ 를 기반으로 구축된 비동기적으로 확장 가능한 HTTP(S) Web 프레임웍입니다.

Xitrum `사용자 <https://groups.google.com/group/xitrum-framework/msg/d6de4865a8576d39>`_ 로 부터:

  이것은 정말 인상적인 작품으로 아마도 Lift를 제외하고 가장 완벽한(그리고 아주 쉬운) Scala 프레임웍 입니다.

  `Xitrum <http://xitrum-framework.github.io/>`_ 은 Web 프레임웍의 기본 기능을 모두 충족하는 풀 스택의 Web 프레임웍입니다.
  정말 다행스러운건 ETags, 정적 파일 캐쉬, 자동 gzip 압축, 내장된 JSON 변환기, 인터셉터, 리퀘스트, 세션, 쿠키, 플래시 스코프, 서버와 클라이언트의 통합 검증, 내장된 캐쉬 (`Hazelcast <http://www.hazelcast.org/>`_) 그리고 Netty가 내장된 기능을 바로 사용할 수 있습니다. 와우

기능
----

* Scala 사상에 기초한 Type-Safe. 모든 API는 Type-Safe하도록 디자인되어 있습니다.
* Netty 사상에 기초한 비동기처리. 요청의 처리결과에 대한 액션을 곧바로 반환할 필요가 없습니다.
  Long polling, chunked response (스트리밍), WebSocket, SockJS을 지원합니다.
* `Netty <http://netty.io/>`_ 에 내장된 고속 HTTP(S) 서버.
  (HTTPS는Java엔진과 OpenSSL을 선택할 수 있습니다)
  Xitrum의 정적파일 전송속도는 `Nginx <https://gist.github.com/3293596>`_ 와 비슷합니다.
* 빠른 응답을 위한 광범위한 서버와 클라이언트 캐쉬. 웹 서버 측 에서는 작은 파일은 메모리에 캐쉬되고 큰 파일은 NIO의 zero copy를 사용하여 전송됩니다.
  웹 프레임웍 측에서는 Rails스타일 처럼 page, action, object cache를 사용합니다.
  `All Google's best practices <http://code.google.com/speed/page-speed/docs/rules_intro.html>`_ 에 있는것 처럼,
  조건적으로 GET 에대해 클라이언트측 Cache가 적용됩니다.
  물론 브라우저에 강제로 요청 및 재전송을 할 수 있습니다.
* 정적 파일에 대한 `Range requests <http://en.wikipedia.org/wiki/Byte_serving>`_ 지원.
  이 기능으로 모바일에 동영상 전송이나 모든 클라이언트에게 파일 전송을 중지하거나 다시 시작할 수 있습니다.
* `CORS <http://en.wikipedia.org/wiki/Cross-origin_resource_sharing>`_ 지원.
* JAX-RS 와 Rails엔진의 사상에 기초한 자동 라우트 수집. 모든 경로에 대해서 하나의 파일에 선언할 필요가 없습니다.
  이 기능은 분산 라우팅을 위해 고려되었습니다. 이 기능으로 인해 어플리케이션을 다른 어플리케이션에 통합이 가능합니다.
  만약 당신이 블로그엔진을 만든다면 그것을 JAR처럼 다른 어플리케이션으로 통합하는 즉시 블로그 기능을 사용할 수 있게 합니다.
  라우팅에는 두 가지 특징이 있습니다.
  Type-Safe한 방법으로 URL을 재생성하거나(리버스 라우팅)
  `Swagger Doc <http://swagger.wordnik.com/>`_ 을 이용하여 문서화 할 수 있습니다.
* Develop Mode에서는 클래스 파일과 라우트 정보는 자동으로 갱신됩니다.
* View는 독립적인 `Scalate <http://scalate.fusesource.org/>`_ 템플릿이나
  Scala의 인라인 XML로 작성되고 모두 Type-Safe합니다.
* Cookie에 의한(더 확장가능한) `Hazelcast <http://www.hazelcast.org/>`_ 클러스터를 이용한(보다 안전한) 세션 관리.
  Hazelcast는, 매우 빠르고 쉬운, 프로세스간 분산 Cache도 제공합니다.
  굳이 다른 캐시 서버를 준비 할 필요는 없습니다. 이것은 Akka의 pubsub 기능도 마찬가지입니다.
* `jQuery Validation <http://jqueryvalidation.org/>`_ 를 이용한 브라우저와 서버의 양쪽 검증.
* `GNU gettext <http://en.wikipedia.org/wiki/GNU_gettext>`_ 를 사용한 국제화.
  텍스트의 추출과 번역이 자동으로 이루어져서 번잡한 속성 파일은 필요하지 않습니다.
  번역과 통합작업에는 `Poedit <http://www.poedit.net/screenshots.php>`_ 와 같은 강력한 도구를 사용할 수 있습니다.
  gettext는 대부분의 다른 솔루션과 달리 단수와 복수 두 형식을 모두 지원하고 있습니다.

Xitrum은 `Scalatra <https://github.com/scalatra/scalatra>`_ ,
`Lift <http://liftweb.net/>`_ 두 가지 특징을 모두 사용하려고 합니다: Scalatra보다 강력하고 Lift보다 사용하기 쉬운 것이 특징입니다.
`Xitrum <http://xitrum-framework.github.io/>`_ 은 많은 개발자에게 친숙한 controller-first를 사용하기 위해 Scalatra의 controller-first를 Lift의 `view-first <http://www.assembla.com/wiki/show/liftweb/View_First>`_ 를 적용하지 않았습니다.


:doc:`연관된 프로젝트 </deps>` 샘플, 플러그인 등의 프로젝트 목록을 참고하세요.

기여자들
--------

`Xitrum <http://xitrum-framework.github.io/>`_ 은 `오픈소스 <https://github.com/xitrum-framework/xitrum>`_ 프로젝트입니다.
`Google group <http://groups.google.com/group/xitrum-framework>`_. 에 가입하세요.

기여자들은 `공헌한 날 <https://github.com/xitrum-framework/xitrum/graphs/contributors>`_ 의 순서대로 되어있습니다:

(*): 현재 코어 개발자들ー

* `Ngoc Dao (*) <https://github.com/ngocdaothanh>`_
* `Linh Tran <https://github.com/alide>`_
* `James Earl Douglas <https://github.com/earldouglas>`_
* `Aleksander Guryanov <https://github.com/caiiiycuk>`_
* `Takeharu Oshida (*) <https://github.com/georgeOsdDev>`_
* `Nguyen Kim Kha <https://github.com/kimkha>`_
* `Michael Murray <https://github.com/murz>`_
