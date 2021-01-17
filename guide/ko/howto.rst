HOWTO
=====

이 장에서는 몇가지 작은 팁들을 제공합니다.

기본적인 인증
--------------

사이트나 특정 액션에 `Basic authentication <http://ja.wikipedia.org/wiki/Basic%E8%AA%8D%E8%A8%BC>`_ 을 이용하여 보호할 수 있습니다.

Xitrum은 `digest authentication <http://ja.wikipedia.org/wiki/Digest%E8%AA%8D%E8%A8%BC>`_ 을 지원하지 않습니다
잘못된 보안 방법으로 인해 man-in-the-middle attack에 취약하므로 보다 나은 방법으로서 Xitrum을 이용하여 HTTPS를 사용하는 것을 권장합니다.
(Apache나 Nginx와 같은 리버스 프록시를 따로 구축할 필요가 없습니다)

전체 프로젝트에 기본적인 인증을 설정하는 방법
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``config/xitrum.conf`` 내부에 설정:

::

  "basicAuth": {
    "realm":    "xitrum",
    "username": "xitrum",
    "password": "xitrum"
  }

특정 액션에 기본 인증을 추가
~~~~~~~~~~~~~~~~~~~~~

::

  import xitrum.Action

  class MyAction extends Action {
    beforeFilter {
      basicAuth("Realm") { (username, password) =>
        username == "username" && password == "password"
      }
    }
  }

설정파일 로드
----------

JSON 파일
~~~~~~~~

JSON은 중첩된 구조를 설명하기에 알맞습니다.

``config`` 디렉토리에 설정 파일을 저장합니다.
이 디렉토리는, 개발 모드에서 build.sbt에 의해, 프로덕션 모드에서는 ``script/runner`` (또는 ``script/runner.bat``) 에 의해 자동적으로 클래스 패스에 포함됩니다.

myconfig.json:

::

  {
    "username": "God",
    "password": "Does God need a password?",
    "children": ["Adam", "Eva"]
  }

로드방법:

::

  import xitrum.util.Loader

  case class MyConfig(username: String, password: String, children: Seq[String])
  val myConfig = Loader.jsonFromClasspath[MyConfig]("myconfig.json")

주의:

* 키와 스트링은 큰따옴표로 둘러싸여 있어야 합니다.
* 현재는 JSON파일에 주석을 달 수 없습니다.

설정 파일
~~~~~

설정 파일을 사용할 수도 있습니다만 설정 파일은 안전하지 않고 UTF-8을 지원하지 않을뿐더러 중첩된 구조도 지원하지 않으므로
JSON을 사용하는 것이 훨씬 좋습니다.

myconfig.properties:

::

  username = God
  password = Does God need a password?
  children = Adam, Eva

로드 방법:

::

  import xitrum.util.Loader

  // Here you get an instance of java.util.Properties
  val properties = Loader.propertiesFromClasspath("myconfig.properties")

Typesafe한 설정파일
~~~~~~~~~~~~~~~~~~~~

Xitrum은 Akka를 포함하고 있습니다. Akka는 `Typesafe <http://typesafe.com/company>`_ 사의 `config library <https://github.com/typesafehub/config>`_ 라고 하는 라이브러리를 포함하고 있으며 더 나은 설정 방법을 제시합니다.

myconfig.conf:

::

  username = God
  password = Does God need a password?
  children = ["Adam", "Eva"]

로드 방법:

::

  import com.typesafe.config.{Config, ConfigFactory}

  val config   = ConfigFactory.load("myconfig.conf")
  val username = config.getString("username")
  val password = config.getString("password")
  val children = config.getStringList("children")

직렬화 및 역직렬화
----------------------------

``Array[Byte]`` 를 직렬화:

::

  import xitrum.util.SeriDeseri
  val bytes = SeriDeseri.toBytes("my serializable object")

다시 역직렬화:

::

  val option = SeriDeseri.fromBytes[MyType](bytes)  // Option[MyType]

파일에 저장 시:

::

  import xitrum.util.Loader
  Loader.bytesToFile(bytes, "myObject.bin")

파일에서 로드 시:

::

  val bytes = Loader.bytesFromFile("myObject.bin")

데이터 암호화
--------------

다시 해독할 필요가 없는 데이터일 경우에는 MD5등을 사용할 수 있습니다.(단방향 암호화)
다시 해독할 필요가 있는 데이터일 경우에는 Xitrum에서 제공하는 라이브러리를 사용하면 됩니다.

::

  import xitrum.util.Secure

  // Array[Byte]
  val encrypted = Secure.encrypt("my data".getBytes)

  // Option[Array[Byte]]
  val decrypted = Secure.decrypt(encrypted)

``xitrum.util.UrlSafeBase64`` 을 이용하여 바이너리 데이터(HTML을 이용한 응답 등을 포함)를 일반적인 스트링값으로 암복호화가 가능합니다.

::

  // cookie와 같이 URL내에 포함된 스트링
  val string = UrlSafeBase64.noPaddingEncode(encrypted)

  // Option[Array[Byte]]
  val encrypted2 = UrlSafeBase64.autoPaddingDecode(string)

두 가지를 한 번에 결합할 수 있습니다:

::

  import xitrum.util.SeriDeseri

  val mySerializableObject = new MySerializableClass

  // String
  val encrypted = SeriDeseri.toSecureUrlSafeBase64(mySerializableObject)

  // Option[MySerializableClass]
  val decrypted = SeriDeseri.fromSecureUrlSafeBase64[MySerializableClass](encrypted)

``SeriDeseri`` 는 `Twitter Chill <https://github.com/twitter/chill>`_ 를 사용하여 직렬화 및 역직렬화를 합니다.
데이터는 반드시 직렬화가 가능 해야 합니다.

특정한 키를 암호화:

::

  val encrypted = Secure.encrypt("my data".getBytes, "my key")
  val decrypted = Secure.decrypt(encrypted, "my key")

::

  val encrypted = SeriDeseri.toSecureUrlSafeBase64(mySerializableObject, "my key")
  val decrypted = SeriDeseri.fromSecureUrlSafeBase64[MySerializableClass](encrypted, "my key")

키가 지정되어 있지 않은 경우에는 ``config/xitrum.conf`` 파일 내의 ``secureKey`` 가 사용됩니다.

동일한 도매인 내의 여러 사이트
----------------------------------------

Nginx와 같은 리버스 프록시를 사용하여 같은 도메인 내의 여러 다른 사이트를 실행:

::

  http://example.com/site1/...
  http://example.com/site2/...

``config/xitrum.conf`` 내의 ``baseUrl`` 을 정의합니다.

JavaScript코드 내에서 Ajax 요청에 정확한 URLs을 얻으려면 `xitrum.js <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/js.scala>`_ 내의 ``withBaseUrl`` 을 사용하면 됩니다.

::

  # 만약 현재 사이트의 baseUrl이 "site1" 일 경우에 결과는:
  # 다음과 같습니다. /site1/path/to/my/action
  xitrum.withBaseUrl('/path/to/my/action')

Markdown 텍스트를 HTML로 변환
------------------------

프로젝트가 이미 :doc:`Scalate </template_engines>` 을 사용하고 있다면 다음과 같이 해야 합니다:

::

  import org.fusesource.scalamd.Markdown
  val html = Markdown("input")


아니라면 라이브러리를 프로젝트의 build.sbt에 추가해야 합니다:

::

  libraryDependencies += "org.fusesource.scalamd" %% "scalamd" % "1.6"

임시 디렉토리
----------

기본적으로 Xitrum은 ``tmp`` 디렉토리 (``xitrum.conf`` 의 ``tmpDir`` 에서 확인가능)를 생성된 scala파일의 저장이나 큰 업로드용 파일들을
저장하기 위해 사용합니다.

파일 경로 얻어오기:

::

  xitrum.Config.xitrum.tmpDir.getAbsolutePath

파일이나 디렉토리 생성:

::

  val file = new java.io.File(xitrum.Config.xitrum.tmpDir, "myfile")

  val dir = new java.io.File(xitrum.Config.xitrum.tmpDir, "mydir")
  dir.mkdirs()

비디오 스트리밍
-----------

다양한 비디오 스트리밍 방법 중 쉬운 방법은:

* .mp4 비디오 파일들에 간격을 주어서 플래이하는 동안 다운로드를 합니다.
* 그리고 Xitrum이 지원하는 HTTP서버와 같이 `range requests <http://en.wikipedia.org/wiki/Byte_serving>`_ 사용자는 다운로드 받지 않은 부분에 대하여
  건너뛰기가 가능합니다.

`MP4Box <http://gpac.wp.mines-telecom.fr/mp4box/>`_ 를 이용하는 것으로 500 밀리초마다 데이터를 넣을 수 있습니다.

::

  MP4Box -inter 500 movie.mp4
