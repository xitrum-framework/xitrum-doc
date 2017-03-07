정적 파일
============

디스크의 정적 파일 전송
------------------------------

프로젝트 디렉토리의 레이아웃:

::

  config
  public
    favicon.ico
    robots.txt
    404.html
    500.html
    img
      myimage.png
    css
      mystyle.css
    js
      myscript.js
  src
  build.sbt

Xitrum은 ``public`` 디렉토리의 정적 파일들을 자동으로 제공합니다.
URLs는 다음과 같이 사용합니다:

::

  /img/myimage.png
  /css/mystyle.css
  /css/mystyle.min.css

참조하려면:

::

  <img src={publicUrl("img/myimage.png")} />

일반 파일을 개발환경에서 사용하고 압축된 버전의 파일을 프로덕션 환경에서 사용하려면
(위의 mystyle.css와 mystyle.min.css):

::

  <img src={publicUrl("css", "mystyle.css", "mystyle.min.css")} />

디스크의 정적 파일을 액션을 통해 전송하려면 ``respondFile`` 을 사용합니다.

::

  respondFile("/absolute/path")
  respondFile("path/relative/to/the/current/working/directory")

정적 파일의 전송 속도를 최적화 하기 위해
정규식 필터를 통해, 불필요한 파일의 존재를 체크하여 미연에 방지할 수 있습니다.
만약 요청된 URL이 pathRegex와 맞지 않으면 Xitrum은 해당 요청에 404를 응답합니다.

``config/xitrum.conf`` 의 ``pathRegex`` 를 참고하세요.

index.html 대체
--------------

만약 ``/foo/bar`` (또는 ``/foo/bar/``) URL의 경로(액션)가 없을 경우
Xitrum은 ``public/foo/bar/index.html`` ("public" 디렉토리) 경로의 정적 파일을 탐색합니다.
파일이 존재하면 Xitrum은 해당파일을 클라이언트로 응답합니다.

404 과 500
-----------

요청에 대해 적합한 경로가 없거나 에러가 발생한 경우에는 ``public`` 디렉토리에 있는 404.html과 500.html이 사용됩니다.
핸들러를 직접 등록하고 싶은 경우:

::

  import xitrum.Action
  import xitrum.annotation.{Error404, Error500}

  @Error404
  class My404ErrorHandlerAction extends Action {
    def execute() {
      if (isAjax)
        jsRespond("alert(" + jsEscape("Not Found") + ")")
      else
        renderInlineView("Not Found")
    }
  }

  @Error500
  class My500ErrorHandlerAction extends Action {
    def execute() {
      if (isAjax)
        jsRespond("alert(" + jsEscape("Internal Server Error") + ")")
      else
        renderInlineView("Internal Server Error")
    }
  }

응답에 대한 요청은 액션이 수행되기 전에 404과 500이 세팅되므로 임의로 세팅할 필요가 없습니다.

WebJar에 의한 클래스 패스내의 리소스 파일 전송
------------------------------------

WebJars
~~~~~~~

`WebJars <http://www.webjars.org/>`_ 는 상당량의 웹 라이브러리를 제공하고 프로젝트 내에서
정의해 사용할 수 있습니다.

예를 들어 `Underscore.js <http://underscorejs.org/>`_ 를 사용하고자 하는 경우에는
프로젝트의 ``build.sbt`` 내에 정의하면 됩니다.

::

  libraryDependencies += "org.webjars" % "underscorejs" % "1.6.0-3"

그리고 .jade 템플릿 파일에서 사용됩니다:

::

  script(src={webJarsUrl("underscorejs/1.6.0", "underscore.js", "underscore-min.js")})

Xitrum은 자동으로 개발환경에서 ``underscore.js`` 를 사용하고　``underscore-min.js`` 를
프로덕션 환경에서 사용합니다.

결과는 다음과 같습니다:

::

  /webjars/underscorejs/1.6.0/underscore.js?XOKgP8_KIpqz9yUqZ1aVzw

동일한 파일을 동일 환경에서 사용하려면:

::

  script(src={webJarsUrl("underscorejs/1.6.0/underscore.js")})

종속된 파일들은 자동으로 다운로드 됩니다. 버전 충돌의 문제로 원하는 버전의 라이브러리가 선택되지 않았을 경우(``sbt xitrum-package`` 명렁어를 통해 다음에 생성되는 디렉토리의 파일들을 보고 확인할 수 있습니다. ``target/xitrum/lib``), ``dependencyOverrides`` 에서 강제로 원하는 버전의 라이브러리를 추가할 수 있습니다. 예를 들어, jQuery 2.x 이 선택되었지만 인터넷 익스플로러 6, 7, 8에서 강제로 jQuery 1.x 사용하기를 원할 경우엔 다음과 같이 사용하면 됩니다:

::

  dependencyOverrides += "org.webjars" % "jquery" % "1.11.3"

WebJars 형식으로 리소스 파일을 .jar 내에 저장하기
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

만약 라이브러리를 개발하여 라이브러리에 myimage.png를 추가하고 싶다면
`WebJars <http://www.webjars.org/>`_ 의 형식으로 .jar 파일의 클래스 패스에
myimage.png를 넣을 수 있습니다:

::

  META-INF/resources/webjars/mylib/1.0/myimage.png

사용법:

::

  <img src={webJarsUrl("mylib/1.0/myimage.png")} />

개발환경과 프로덕션 환경 모두에서 URL은:

::

  /webjars/mylib/1.0/myimage.png?xyz123

클래스 패스내의 파일 응답
~~~~~~~~~~~~~~~~~~~~~~~~~

클래스 패스내의 `WebJars <http://www.webjars.org/>`_ 형식으로 저장되지 않은 파일의 응답:


::

  respondResource("path/relative/to/the/classpath/element")

예:

::

  respondResource("akka/actor/Actor.class")
  respondResource("META-INF/resources/webjars/underscorejs/1.6.0/underscore.js")
  respondResource("META-INF/resources/webjars/underscorejs/1.6.0/underscore-min.js")


ETag 과 max-age의 클라이언트 캐쉬
----------------------------

Xitrum은 자동으로 `Etag <http://ja.wikipedia.org/wiki/HTTP_ETag>`_ 을 디스크 내 클래스 패스의 정적파일을 사용하기 위해 추가합니다.

ETags는 작은 파일일 경우 MD5로 캐쉬되어 나중에 사용됩니다. 캐쉬 앤트리의 키는 ``(파일경로, 수정시간)`` 입니다. 왜냐하면 파일의 변경시간은 각 서버별로 상이하기 때문에
클러스터의 각 서버는 각각 로컬 ETag 캐쉬를 가지게 됩니다.

큰 파일의 경우에는 수정된 시간만을 ETag에 사용됩니다. 완벽하지는 않지만 각기 서버는 다른 ETag 정보를 가질 것으로 예상되기 때문입니다.
물론 ETag를 사용하지 않는 경우보다는 약간 낫다고 보여집니다.

``publicUrl`` 과 ``resourceUrl`` 은 자동으로 Etag가 추가되어 URLs이 생성됩니다:

::

  webJarsUrl("jquery/2.1.1/jquery.min.js")
  => /webjars/jquery/2.1.1/jquery.min.js?0CHJg71ucpG0OlzB-y6-mQ


Xitrum은 헤더의 ``max-age`` 와 ``Expires`` 를 `1 년 <https://developers.google.com/speed/docs/best-practices/caching>`_ 으로 설정합니다.
브라우저가 최신 파일을 참조하지 못할 것을 염려하지 않아도 됩니다.
왜냐하면 디스크의 파일이 변경될 때 ``수정시간`` 이 변하게 되고
``publicUrl`` 과 ``resourceUrl`` 이 변하게 된 상태로 생성되기 때문입니다.
ETag 캐쉬 또한 업데이트 되기 때문에 키도 변하게 됩니다.

GZIP
----

Xitrum은 자동으로 텍스트 형식의 응답을 gzips을 적용합니다. ``Content-Type`` 헤더를 통해 형식이
``text/html``, ``xml/application`` 등과 같은 텍스트 형식인지를 체크해서 결정합니다.

Xitrum은 정적 파일에 대해서는 항상 gzips을 수행하지만 동적인 텍스트 응답에 대해서는 성능 최적화를 위해
1 KB 미만의 응답에 대해서는 gzips을 수행하지 않습니다.

서버 캐쉬
-------

디스크로부터 파일 로딩을 방지하기 위해 Xitrum은 작은 정적파일에 대해서(텍스트 뿐만 아니라)
메모리에 LRU (Least Recently Used) 알고리즘을 사용합니다.

``config/xitrum.conf`` 내의 ``small_static_file_size_in_kb`` 와 ``max_cached_small_static_files`` 에서 확인할 수 있습니다.
