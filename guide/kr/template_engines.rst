템플릿 엔진
========

:doc:`renderView 이나 renderFragment, respondView <./action_view>` 이 호출되면
설정된 템플릿 엔진이 호출됩니다.

템플릿 엔진 설정
------------

`config/xitrum.conf <https://github.com/xitrum-framework/xitrum-new/blob/master/config/xitrum.conf>`_ 에서 템플릿 엔진은 그 형식에 따라서 다음과 같이 두 종류로 설정이 가능합니다.

::

  template = my.template.EngineClassName

또는:

::

  template {
    "my.template.EngineClassName" {
      option1 = value1
      option2 = value2
    }
  }

기본 템플릿 엔진은 `xitrum-scalate <https://github.com/xitrum-framework/xitrum-scalate>`_ 입니다.

템플릿 엔진 제거
------------

단지 RESTful API만을 만들경우、renderView、renderFragment、respondView를 호출 할 필요가 없습니.이 경우 템플릿 엔진을 프로젝트에서 삭제해서 프로젝트를 더 가볍게 만들 수 있습니다.
방법은 config/xitrum.conf 에서 ``templateEngine`` 을 지우거나 주석처리 하세요.

템플릿 엔진 만들기
--------------

나민의 템플릿 엔진을 만들려、 `xitrum.view.TemplateEngine <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/view/TemplateEngine.scala>`_ 을 상속받아 클라스를 만들고.
그러고 나서 config/xitrum.conf 에 명시하면 됩니다.

예제: `xitrum-scalate <https://github.com/xitrum-framework/xitrum-scalate>`_
