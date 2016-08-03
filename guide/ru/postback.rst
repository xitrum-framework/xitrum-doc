Postbacks
=========

Клиентами веб приложения могут быть:

* другие приложения или устройства: например, RESTful APIs которое широко используется смартфонами, другими веб сайтами
* люди: например, интерактивные веб сайты предполагающие сложные взаимодействия

Как фреймворк, Xitrum нацелен на создание легких решений для этих задача.
Для решения первой задачи, используются :doc:`RESTful контроллеры </restful>`.
Для решения второй задачи, в том числе существует возможность использовать postback.
Подробнее о технологии postback:

* http://en.wikipedia.org/wiki/Postback
* http://nitrogenproject.com/doc/tutorial.html

Реализация в Xitrum's сделана в стиле `Nitrogen <http://nitrogenproject.com/>`_.

Шаблон
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

Форма
-----

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

  @First  // Этот маршрут будет обработан перед "show"
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

При возникновении события ``submit`` формы, состояние формы будет отправлено на сервер в контроллер ``ArticlesCreate``.

Атрибут ``action`` формы зашифрован. Зашифрованный URL выступает в роли anti-CSRF токена.

Другие элементы (не формы)
--------------------------

Postback может быть отправлен для любого элемента, не только для формы.

Вот пример для ссылки:

::

  <a href="#" data-postback="click" action={postbackUrl[LogoutAction]}>Logout</a>

Переход по ссылке выполнит отправку состояния в LogoutAction.

Диалог подтверждения
--------------------

Отображение диалоговых окон подтверждения:

::

  <a href="#" data-postback="click"
              action={postbackUrl[LogoutAction]}
              data-confirm="Do you want to logout?">Logout</a>

В случае отказа от продолжения (при нажатии кнопки "Cancel") postback не будет отправлен.


Дополнительные параметры
------------------------

В случае формы вы можете добавлять дополнительные поля ``<input type="hidden"...`` для отправки
дополнительных параметров как часть postback.

Для других элементов, вы можете поступать так:

::

  <a href="#"
     data-postback="click"
     action={postbackUrl[ArticlesDestroy]("id" -> item.id)}
     data-params="_method=delete"
     data-confirm={"Do you want to delete %s?".format(item.name)}>Delete</a>

Или вы можете поместить дополнительные параметры в смежную форму:

::

  <form id="myform" data-postback="submit" action={postbackUrl[SiteSearch]}>
    Search:
    <input type="text" name="keyword" />

    <a class="pagination"
       href="#"
       data-postback="click"
       data-form="#myform"
       action={postbackUrl[SiteSearch]("page" -> page)}>{page}</a>
  </form>

Используйте селектор ``#myform`` для получения формы с дополнительными параметрами.

Отображение анимации во время Ajax загрузки
-------------------------------------------

By default, this animated GIF image is displayed while Ajax is loading:

.. Use ../img/ajax_loading.png for PDF (make latexpdf) because it can't include animation GIF

.. image:: ../img/ajax_loading.gif

To customize, please call this JS snippet after including ``jsDefaults`` (which includes
`xitrum.js <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/js.scala>`_)
in your view template:

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
