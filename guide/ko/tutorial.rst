튜토리얼
======

이 장에서는 Xitrum 프로젝트를 만들고 실행하는데 까지를 간단하게 소개합니다.

**이 과정은 Java 가 설치된 Linux 환경을 가정하고 있습니다.**

Xitrum 프로젝트 만들기
------------------

새 프로젝트를 만들려면
`xitrum-new.zip <https://github.com/xitrum-framework/xitrum-new/archive/master.zip>`_ 를다운로드 합니다.

::

  wget -O xitrum-new.zip https://github.com/xitrum-framework/xitrum-new/archive/master.zip

또는:

::

  curl -L -o xitrum-new.zip https://github.com/xitrum-framework/xitrum-new/archive/master.zip

시작하기
------

Scala 빌드 도구로써 사실상 표준인 `SBT <https://github.com/harrah/xsbt/wiki/Setup>`_ 를 사용합니다.
방금 다운로드한 프로젝트에는 이미 SBT 0.13 이 ``sbt`` 디렉토리에 포함되어 있습니다.
SBT를 직접설치 하려면 、SBT의  `설치가이드 <https://github.com/harrah/xsbt/wiki/Setup>`_ 를 참고하세요.

생성한 프로젝트의 루트 디렉토리에 ``sbt/sbt run`` 을 실행하면 Xitrum 이 시작됩니다:

::

  unzip xitrum-new.zip
  cd xitrum-new
  sbt/sbt run


이 명령은 의존 라이브러리( :doc:`dependencies </deps>` )의 다운로드 및 프로젝트 컴파일 후에
``quickstart.Boot`` 클래스가 실행되고、WEB서버가 시작됩니다.
콘솔에는 다음과 같은 라우팅 정보가 표시됩니다.

::

  [INFO] Load routes.cache or recollect routes...
  [INFO] Normal routes:
  GET  /  quickstart.action.SiteIndex
  [INFO] SockJS routes:
  xitrum/metrics/channel  xitrum.metrics.XitrumMetricsChannel  websocket: true, cookie_needed: false
  [INFO] Error routes:
  404  quickstart.action.NotFoundError
  500  quickstart.action.ServerError
  [INFO] Xitrum routes:
  GET        /webjars/swagger-ui/2.0.17/index                            xitrum.routing.SwaggerUiVersioned
  GET        /xitrum/xitrum.js                                           xitrum.js
  GET        /xitrum/metrics/channel                                     xitrum.sockjs.Greeting
  GET        /xitrum/metrics/channel/:serverId/:sessionId/eventsource    xitrum.sockjs.EventSourceReceive
  GET        /xitrum/metrics/channel/:serverId/:sessionId/htmlfile       xitrum.sockjs.HtmlFileReceive
  GET        /xitrum/metrics/channel/:serverId/:sessionId/jsonp          xitrum.sockjs.JsonPPollingReceive
  POST       /xitrum/metrics/channel/:serverId/:sessionId/jsonp_send     xitrum.sockjs.JsonPPollingSend
  WEBSOCKET  /xitrum/metrics/channel/:serverId/:sessionId/websocket      xitrum.sockjs.WebSocket
  POST       /xitrum/metrics/channel/:serverId/:sessionId/xhr            xitrum.sockjs.XhrPollingReceive
  POST       /xitrum/metrics/channel/:serverId/:sessionId/xhr_send       xitrum.sockjs.XhrSend
  POST       /xitrum/metrics/channel/:serverId/:sessionId/xhr_streaming  xitrum.sockjs.XhrStreamingReceive
  GET        /xitrum/metrics/channel/info                                xitrum.sockjs.InfoGET
  WEBSOCKET  /xitrum/metrics/channel/websocket                           xitrum.sockjs.RawWebSocket
  GET        /xitrum/metrics/viewer                                      xitrum.metrics.XitrumMetricsViewer
  GET        /xitrum/metrics/channel/:iframe                             xitrum.sockjs.Iframe
  GET        /xitrum/metrics/channel/:serverId/:sessionId/websocket      xitrum.sockjs.WebSocketGET
  POST       /xitrum/metrics/channel/:serverId/:sessionId/websocket      xitrum.sockjs.WebSocketPOST
  [INFO] HTTP server started on port 8000
  [INFO] HTTPS server started on port 4430
  [INFO] Xitrum started in development mode

처음 실행시에는 、모든 라우팅을 수집하여 로그에 기록합니다.
이 정보는 어플리케이션의 RESTful API에 대한 문서를 작성하는 경우 이 정보는 매우 유용하게 사용될 수 있습니다.

브라우저에서 `http://localhost:8000 <http://localhost:8000/>`_ 또는 `https://localhost:4430 <http://localhost:4430/>`_ 에 접근하게 되면.
다음과 같은 요청정보를 확인 할수 있습니다.

::

  [INFO] GET quickstart.action.SiteIndex, 1 [ms]

Eclipse 프로젝트로 만들기
-------------------

`Eclipse <http://scala-ide.org/>`_ 개발환경 을 사용하는 경우

프로젝트 디렉토리에서 다음 명령을 실행합니다 :

::

  sbt/sbt eclipse

``build.sbt`` 에 기재된 프로젝트 설정에 따라 Eclipse용  ``.project`` 파일이 생성됩니다.
Eclipse를 열고 프로젝트를 임포트 합니다.

IntelliJ IDEA프로젝트 만들기
------------------------

`IntelliJ IDEA <http://www.jetbrains.com/idea/>`_ 개발환경을 사용하는 경우

그 스칼라 플러그인 설치 로、 간단하게、 당신의 SBT 프로젝트를 엽니 다
는 프로젝트 파일 을 생성 할 필요가 없다.

자동 리로드
--------

프로그램을 다시 시작하지 않고 .class파일을 다시 로드（핫 스왑)할 수 있습니다.
그러나、프로그램의 성능과 안정성을 위하여、자동 리로드는 개발시에만 사용하는것을 권장합니다.

IDE를 사용하는 경우
~~~~~~~~~~~~~~~

최신의 Eclipse 나 IntelliJ와 같은 IDE를 사용하여 개발하여 시작하는 경우、
기본적으로 IDE가 소스코드의 변경을 감지하고、변경이 있을경우 자동으로 컴파일 해줍니.

SBT를 사용하는 경우
~~~~~~~~~~~~~~~

SBT를 사용하는 경우、2가지의 콘솔창을 준비하여야 합니다:

* 하나는 ``sbt/sbt run`` 을 실행합니다. 이 명령은 프로그램을 실행하여、 .class 파일에 변경이 있을경우 다시 로드합니다.
* 다른 하나는  ``sbt/sbt ~compile`` 를 실행합니다. 다이 명령은 소스 코드의 변경을 감지하여 、변경이 있을경우 .class 파일로 컴파일합니다.

sbt디렉토리 `agent7.jar <https://github.com/xitrum-framework/agent7>`_ 이 포함되어 있습니다.
이 라이브러리는、현재 디렉토리（및 하위 디렉토리)의 .class 파일 리로드를 담당합니다.
``sbt/sbt`` 스크립트 중에 ``-javaagent:agent7.jar`` 로 사용되고 있습니다.

DCEVM
~~~~~

일반JVM은 클래스 파일이 다시 로드 되었을때、메소드의 바디부분만 변경이 반영됩니다.
오픈소스인 `DCEVM <https://github.com/dcevm/dcevm>`_ 의 Java HotSpot VM 를 사용하여、
로드된 클래스의 재정의를 보다 유연하게 할 수 있습니다.

DCEVM은 다음의 두가지 방법으로 설치 할 수 있습니:

* 이미 설치된 Java에  `Patch <https://github.com/dcevm/dcevm/releases>`_ 하는 방법
* `prebuilt <http://dcevm.nentjes.com/>`_ 버전설치 (이 쪽이 간단합니다)

패치를 사용하여 설치하는 경우:

* DCEVM를 항상 활성화 할 수 있습니.
* 또는 DCEVM 를 "alternative" JVM 으로 적용할 수 있습니다.
  이 경우、``java`` 명령에 ``-XXaltjvm=dcevm`` 옵션을 지정하여 DCEVM를 사용할 수 있습니.
  예를 들어、 ``sbt/sbt`` 스크립트 파일에 ``-XXaltjvm=dcevm`` 를 추가해야 합니다.

Eclipse나 IntelliJ와 같은 IDE를 사용하는 경우 、DCEVM은 프로젝트의 실행 JVM를 지정해야 합니다.

SBT를 사용하는 경우、 ``java`` 명령이 DCEVM를 사용할 수 있도록  ``PATH`` 환경변수를 지정해 줘야 합니다.
DCEVM는 자체 클래스의 변경을 지원하지만、새로고침을 하지 않기 때문에 、DCEVM를 사용하는 경우에도  ``javaagent`` 가 필요합니다.

자세한 내용은 `DCEVM - A JRebel free alternative <http://javainformed.blogspot.jp/2014/01/jrebel-free-alternative.html>`_ 를 참고하세요.

무시되는 파일들
-------------

:doc:`튜토리얼 </tutorial>` 에 따라 프로젝트를 만든경우 `ignored <https://github.com/xitrum-framework/xitrum-new/blob/master/.gitignore>`_ 를 참고 하여 ignore 파일을 작성하세요.

::

  .*
  log
  project/project
  project/target
  target
  tmp
