검증
====

Xitrum은 클라이언트 검증을 위해 `jQuery Validation plugin <http://bassistance.de/jquery-plugins/jquery-plugin-validation/>`_
내포하고 있고 서버 검증을 위해 핼퍼를 제공합니다.

기본 검증
----------------------

``xitrum.validator`` 패키지에 검증기를 제공합니다.
다음과 같은 메소드를 가지고 있습니다:

::

  check(value): Boolean
  message(name, value): Option[String]
  exception(name, value)

검증을 통과 하지 못하면, ``message`` 는 ``Some(error message)`` 를 반환하고
``exception`` 은 ``xitrum.exception.InvalidInput(error message)`` 를 호출합니다.

어디서든지 검증기를 사용할 수 있습니다.

Action 예제:

::

  import xitrum.validator.Required

  @POST("articles")
  class CreateArticle {
    def execute() {
      val title = param("tite")
      val body  = param("body")
      Required.exception("Title", title)
      Required.exception("Body",  body)

      // Do with the valid title and body...
    }
  }

``try`` 、 ``catch`` 를 사용하지 않은 구문에서 검증을 통과하지 못하면
xitrum은 자동으로 예외를 탐지해서 클라이언트로 에러메세지를 전송합니다.
이것은 클라이언트에서 검증을 사용하거나 웹 APIs를 작성할 때 도움이 됩니다.


Model 예제:

::

  import xitrum.validator.Required

  case class Article(id: Int = 0, title: String = "", body: String = "") {
    def isValid           = Required.check(title)   &&     Required.check(body)
    def validationMessage = Required.message(title) orElse Required.message(body)
  }


`xitrum.validator 패키지에는 <https://github.com/xitrum-framework/xitrum/tree/master/src/main/scala/xitrum/validator>`_
모든 종류의 기본 검증기 리스트가 있습니다.

검증기 수정하기
-----------

`xitrum.validator.Validator <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/validator/Validator.scala>`_ 를 확장할때
``check`` 나 ``message`` 메소드만 확장하면 됩니다.

또한, `Commons Validator <http://commons.apache.org/proper/commons-validator/>`_ 를 사용해도 됩니다.
