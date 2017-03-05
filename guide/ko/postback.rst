포스트백
======

Web 어플리케이션은 다음과 같은 두 가지 경우로 많이 사용됩니다.

* 서버를 위해 사용하는 경우: 스마트폰을 위한 RESTful API를 만들거나, 다른 웹사이트를 위한 웹서비

* 사람을 위해 사용하는 경우: 인터랙티브한 웹 서비스

Web 프레임워크를 기반으로 Xitrum은 이 두가지를 쉽게 사용할 수 있는것을 목표로 하고 있습니다.
1번째 케이스를 사용하기 위해서、:doc:`RESTful actions </restful>` 를 적용하여 대응하고、
2번째 케이스를 사용하기 위해、Ajax폼을 사용하고 있습니다.
아래 링크에서 postback에 대한 개념을 알 수 있습니다.

* http://en.wikipedia.org/wiki/Postback
* http://nitrogenproject.com/doc/tutorial.html

Xitrum은  `Nitrogen <http://nitrogenproject.com/>`_ 영향을 받아서 작성되었습니다.

레이아웃
------

AppAction.scala

::

  import xitrum.Action
  import xitrum.view.DocType

  trait AppAction extends Action {
    override def layout = DocType.html5(
      <html>
        <head>
          {antiCsrfMeta}
          {xitrumCss}
          {jsDefaults}
          <title>Welcome to Xitrum</title>
        </head>
        <body>
          {renderedView}
          {jsForView}
        </body>
      </html>
    )
  }

폼
--

Articles.scala

::

  import xitrum.annotation.{GET, POST, First}
  import xitrum.validator._

  @GET("articles/:id")
  class ArticlesShow extends AppAction {
    def execute() {
      val id      = param("id")
      val article = Article.find(id)
      respondInlineView(
        <h1>{article.title}</h1>
        <div>{article.body}</div>
      )
    }
  }

  @First  // Force this route to be matched before "show"
  @GET("articles/new")
  class ArticlesNew extends AppAction {
    def execute() {
      respondInlineView(
        <form data-postback="submit" action={url[ArticlesCreate]}>
          <label>Title</label>
          <input type="text" name="title" class="required" /><br />

          <label>Body</label>
          <textarea name="body" class="required"></textarea><br />

          <input type="submit" value="Save" />
        </form>
      )
    }
  }

  @POST("articles")
  class ArticlesCreate extends AppAction {
    def execute() {
      val title   = param("title")
      val body    = param("body")
      val article = Article.save(title, body)

      flash("Article has been saved.")
      jsRedirectTo(show, "id" -> article.id)
    }
  }

``submit`` 이벤트가 JavaScript 에서 실행될 때, 폼은 ``ArticlesCreate`` 으로 postback을 보냅니다.
``<form>`` 의 ``action`` 속성은 암호화 되고 암호화된 URL은 CSRF토큰 대신 사용하게 됩니다.


form 이외의 사용
-------------

포스트백은 form이 아닌 HTML 요소에서 사용이 가능합니다.

링크를 사용하는 예제:

::

  <a href="#" data-postback="click" action={url[LogoutAction]}>Logout</a>

링크를 클릭하게 되면 LogoutAction으로 포스트백 메세지를 보냅니다.

확인 다이얼로그
-----------

확인 다이얼로그를 표시하고 싶은 경우:

::

  <a href="#" data-postback="click"
              action={url[LogoutAction]}
              data-confirm="Do you want to logout?">Logout</a>

사용자가 취소를 클릭하게 되면 postback 메세지는 보내지 않습니다.

매개 변수 추가
-----------

form의 요소중  ``<input type="hidden"...`` 를 추가하여 추가 매개변수를 postback메세지로 보낼 수 있습니다.

form요소 이외의 경우에는 다음과 같이 사용하면 됩니다:

::

  <a href="#"
     data-postback="click"
     action={url[ArticlesDestroy]("id" -> item.id)}
     data-params="_method=delete"
     data-confirm={"Do you want to delete %s?".format(item.name)}>Delete</a>

또는 다음과 같이 다른 요소에 지정할 수 있습니다:

::

  <form id="myform" data-postback="submit" action={url[SiteSearch]}>
    Search:
    <input type="text" name="keyword" />

    <a class="pagination"
       href="#"
       data-postback="click"
       data-form="#myform"
       action={url[SiteSearch]("page" -> page)}>{page}</a>
  </form>

``#myform`` 은 JQuery의 선택요소로 폼의 추가 파라미터를 선택하여 보내게 됩니다.

Ajax로딩중 이미지 로딩
-----------------

아래의 로딩 이미지가 Ajax 통신중에 표시됩니다:

.. Use ../img/ajax_loading.png for PDF (make latexpdf) because it can't include animation GIF

.. image:: ../img/ajax_loading.gif

커스터마이즈 시에 템플릿 내에 ``jsDefaults`` (이것은 `xitrum.js <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/js.scala>`_
를 포함하기 위한 함수입니다.)의 뒤에 다음 내용을 추가합니다:

::

  // target: The element that triggered the postback
  xitrum.ajaxLoading = function(target) {
    // Called when the animation should be displayed when the Ajax postback is being sent.
    var show = function() {
      ...
    };

    // Called when the animation should be stopped after the Ajax postback completes.
    var hide = function() {
      ...
    };

    return {show: show, hide: hide};
  };
