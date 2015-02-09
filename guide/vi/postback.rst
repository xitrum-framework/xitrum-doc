Postbacks
=========

Có 2 use case chính của ứng dụng web:

* Để phục vụ các thiết bị: bạn cần tạo các RESTful APIs cho smartphones, web service cho các web site khác.
* Để phục vụ các người dùng cuối: bạn cần tạo giao diện web.

Như một web framework thông thường, Xitrum hướng tới việc hỗ trợ giải quyết các use case một cách dễ dàng. Để giải quyết use case đầu tiền, bạn sử dụng :doc:`RESTful actions </restful>`. Để giải quyết use case thứ hai, bạn có thể sử dụng tính năng Ajax form postback của Xitrum.
Bạn có thể xem thêm các trang dưới đây để biết thêm về postback:
* http://en.wikipedia.org/wiki/Postback
* http://nitrogenproject.com/doc/tutorial.html

Tính năng postback của Xitrum có liên hệ tới `Nitrogen <http://nitrogenproject.com/>`_.

Layout
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

Form
----

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

Khi sự kiện ``submit`` của JavaScript trong form xảy ra, form sẽ postback về ``ArticlesCreate``.

Thuộc tính ``action`` của ``<form>`` được tạo ra. URL được mã hóa hoạt động như một anti-CSRF token.

Non-form
--------

Postback có thể được đặt trong bất kỳ phần tử nào, không chỉ là form.

Một ví dụ sử dụng link:

::

  <a href="#" data-postback="click" action={postbackUrl[LogoutAction]}>Logout</a>

Khi click vào link ở trên sẽ tạo ra postback đến LogoutAction.

Hộp thoại xác nhận
------------------

Nếu bạn muốn hiển thị một hộp thoại xác nhận:

::

  <a href="#" data-postback="click"
              action={url[LogoutAction]}
              data-confirm="Do you want to logout?">Logout</a>

Nếu người dùng click "Cancel", postback sẽ không được gửi đi.

Thêm parameter khác
------------------

Với các form element, bạn có thể thêm ``<input type="hidden"...`` để gửi thêm các parameter khác với postback.

Với các element khác, bạn làm như sau:

::

  <a href="#"
     data-postback="click"
     action={url[ArticlesDestroy]("id" -> item.id)}
     data-params="_method=delete"
     data-confirm={"Do you want to delete %s?".format(item.name)}>Delete</a>

Bạn cũng có thể thêm các parameter trong một form riêng biệt:

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

``#myform`` là một jQuery selector để chọn form có chứa các parameter được thêm vào.

Hiện thị hình động khi load Ajax
--------------------------------

Nếu bạn muốn hiển thị hình ảnh như thế này khi load Ajax

.. Use ../img/ajax_loading.png for PDF (make latexpdf) because it can't include animation GIF

.. image:: ../img/ajax_loading.gif

bạn có thể gọi JS snippet này sau khi đã include ``jsDefaults`` (đã include
`xitrum.js <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/js.scala>`_) trong view template của bạn:

::

  xitrum.ajaxLoadingImg = 'path/to/your/image';
