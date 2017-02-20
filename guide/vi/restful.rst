RESTful APIs
============

Bạn có thể tạo RESTful APIs cho ứng dụng trên iPhone, Android v.v một cách rất dễ dàng.

::

  import xitrum.Action
  import xitrum.annotation.GET

  @GET("articles")
  class ArticlesIndex extends Action {
    def execute() {...}
  }

  @GET("articles/:id")
  class ArticlesShow extends Action {
    def execute() {...}
  }

Tương tự cho các method POST, PUT, PATCH, DELETE, và OPTIONS.
Xitrum tự động kiểm soát phần HEAD như một method GET với phần response body rỗng.

Với các HTTP client như các trình duyệt web thông thường không hỗ trợ method PUT và DELETE, để mô phỏng PUT và DELETE, một thủ thuật được sử dụng là gửi một method POST với ``_method=put`` hoặc ``_method=delete`` trong request body.

Khi các ứng dụng web được khởi chạy, Xitrum sẽ quét tất cả các annotation, xây dựng bảng định tuyến (route) và ghi ra output để thông báo cho bạn biết bạn có APIs nào:

::

  [INFO] Routes:
  GET /articles     quickstart.action.ArticlesIndex
  GET /articles/:id quickstart.action.ArticlesShow

Các Route được tự động gom lại theo tinh thần của JAX-RS và Rails Engines. Bạn không cần khai báo tất cả các route tại cùng một nơi. Hãy xem tính năng này tương tự như distributed route. Bạn có thể sử dụng một ứng dụng trong một ứng dụng khác. Nếu bạn có một blog engine, bạn có thể đóng gói nó thành một tập tin JAR và đặt tập tin JAR đó trong một ứng dụng khác, với cách làm như vậy ứng dụng đó sẽ có thêm tính năng blog.
Việc định tuyến thì bao gồm 2 chiều: bạn có thể tái tạo đường dẫn URL (reverse routing) một cách an toàn từ action.
Bạn có thể tạo tài liệu về các định tuyến bằng cách sử dụng `Swagger Doc <http://swagger.wordnik.com/>`_.

Route cache
-----------

Để khởi động nhanh hơn, route được cache trong file ``routes.cache``.
Trong quá trình phát triển, các route trong các tệp ``*.class`` tại thư mục ``target`` sẽ không được cache. Nếu bạn thực hiện cập nhật các thư viện phụ thuộc có chứa route, bạn có thể cần phải xóa tệp ``routes.cache``. Tệp này không nên được commit đến kho mã nguồn.

Mức độ ưu tiên của các route (first, last)
------------------------------------------
;
Nếu bạn muốn các route như sau:

::

  /articles/:id --> ArticlesShow
  /articles/new --> ArticlesNew

Bạn phải chắc chắn rằng route thứ 2 sẽ được kiểm tra trước.
Nếu bạn muốn ngược lại, annotation ``@First`` sẽ được thêm vào:

::

  import xitrum.annotation.{GET, First}

  @GET("articles/:id")
  class ArticlesShow extends Action {
    def execute() {...}
  }

  @First  // This route has higher priority than "ArticlesShow" above
  @GET("articles/new")
  class ArticlesNew extends Action {
    def execute() {...}
  }

Tương tự cho ``@Last``.

Nhiều đường dẫn cho một action
-----------------------------

::

  @GET("image", "image/:format")
  class Image extends Action {
    def execute() {
      val format = paramo("format").getOrElse("png")
      // ...
    }
  }

Dấu chấm trong route
---------------

::

  @GET("articles/:id", "articles/:id.:format")
  class ArticlesShow extends Action {
    def execute() {
      val id     = param[Int]("id")
      val format = paramo("format").getOrElse("html")
      // ...
    }
  }

Regular Expression trong route
-------------------------------

Regex có thể được sử dụng trong route:

::

  GET("articles/:id<[0-9]+>")

Xử lý các phần còn lại của route
--------------------------------

Kí tự đặc biệt ``/`` không được phép có mặt trong tên của parameter. Nếu bạn muốn sử dụng kí tự này, parameter phải được đặt cuối cùng và bạn phải sử dụng nó như dưới đây:

::

  GET("service/:id/proxy/:*")

Đường dẫn dưới đây sẽ xuất hiện:

::

  /service/123/proxy/http://foo.com/bar

để lấy ra phần ``*``:

::

  val url = param("*")  // Will be "http://foo.com/bar"

Liên kết đến một action
-----------------------

Để bảo toàn tính typesafe của Xitrum, bạn không nên sử dụng URL một cách thủ công, hãy sử dụng cách dưới đây:

::

  <a href={url[ArticlesShow]("id" -> myArticle.id)}>{myArticle.title}</a>

Redirect đến một action khác
---------------------------

Đọc thêm để biết `redirection là gì <http://en.wikipedia.org/wiki/URL_redirection>`_.

::

  import xitrum.Action
  import xitrum.annotation.{GET, POST}

  @GET("login")
  class LoginInput extends Action {
    def execute() {...}
  }

  @POST("login")
  class DoLogin extends Action {
    def execute() {
      ...
      // After login success
      redirectTo[AdminIndex]()
    }
  }

  GET("admin")
  class AdminIndex extends Action {
    def execute() {
      ...
      // Check if the user has not logged in, redirect him to the login page
      redirectTo[LoginInput]()
    }
  }

Bạn cũng có thể redirect đến action hiện tại (current action) với method ``redirectToThis()``.

Forward đến action khác
-----------------------

Sử dụng method ``forwardTo[AnotherAction]()``. Nếu bạn sử dụng method ``redirectTo`` ở trên đây, trình duyệt sẽ tạo một request khác, trong khi đó method ``forwardTo`` thì không.

Xác định Ajax request
---------------------

Sử dụng method ``isAjax``.

::

  // In an action
  val msg = "A message"
  if (isAjax)
    jsRender("alert(" + jsEscape(msg) + ")")
  else
    respondText(msg)

Anti-CSRF
---------

Với các requests, Xitrum mặc định bảo vệ ứng dụng web của bạn khỏi kỹ thuật tấn công `Giả mạo Cross-site request <http://en.wikipedia.org/wiki/CSRF>`_.

Khi bạn incluede ``antiCsrfMeta`` trong layout của bạn:
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

Thẻ ``<head>`` sẽ tưong tự như sau:

::

  <!DOCTYPE html>
  <html>
    <head>
      ...
      <meta name="csrf-token" content="5402330e-9916-40d8-a3f4-16b271d583be" />
      ...
    </head>
    ...
  </html>

Các token sẽ được tự động include trong tất cả các non-GET Ajax requests như ``X-CSRF-Token`` header gửi bởi jQuery nếu bạn include `xitrum.js <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/js.scala>`_ trong view template. ``xitrum.js`` được include trong ``jsDefaults``. Nếu bạn không sử dụng ``jsDefaults``, bạn có thể include ``xitrum.js`` trong template như sau:

::

  <script type="text/javascript" src={url[xitrum.js]}></script>

antiCsrfInput và antiCsrfToken
-------------------------------

Xitrum lấy CSRF token từ ``X-CSRF-Token`` request header. Nếu header không tồn tại, Xitrum sẽ lấy token từ parameter ``csrf-token`` tại request body (chú ý: không phải parameter trong URL).

Nếu bạn tự tạo form, và bạn không sử dụng thẻ meta và xitrum.js như đã trình bày ở trên, bạn cần sử dụng ``antiCsrfInput`` hoặc ``antiCsrfToken``:

::

  form(method="post" action={url[AdminAddGroup]})
    != antiCsrfInput

::

  form(method="post" action={url[AdminAddGroup]})
    input(type="hidden" name="csrf-token" value={antiCsrfToken})

SkipCsrfCheck
-------------

Khi bạn tạo các APIs cho thiết bị, ví dụ điện thoại thông minh, bạn có thể muốn bỏ qua việc tự động kiểm tra CSRS. Thêm trait xitrum.SkipCsrfCheck vào action của bạn:

::

  import xitrum.{Action, SkipCsrfCheck}
  import xitrum.annotation.POST

  trait Api extends Action with SkipCsrfCheck

  @POST("api/positions")
  class LogPositionAPI extends Api {
    def execute() {...}
  }

  @POST("api/todos")
  class CreateTodoAPI extends Api {
    def execute() {...}
  }

Kiểm soát các route
-------------------

Khi khởi động Xitrum sẽ tự động gom các route lại. Nếu bạn muốn điều khiển các route theo cách của mình, bạn có thể sử dụng `xitrum.Config.routes <http://xitrum-framework.github.io/api/3.17/index.html#xitrum.routing.RouteCollection>`_.

Ví dụ:

::

  import xitrum.{Config, Server}

  object Boot {
    def main(args: Array[String]) {
      // You can modify routes before starting the server
      val routes = Config.routes

      // Remove routes to an action by its class
      routes.removeByClass[MyClass]()

      if (demoVersion) {
        // Remove routes to actions by a prefix
        routes.removeByPrefix("premium/features")

        // This also works
        routes.removeByPrefix("/premium/features")
      }

      ...

      Server.start()
    }
  }

Lấy tất cẩ các request content
------------------------------

Thông thường, nếu request content không phải là ``application/x-www-form-urlencoded``, bạn có thể cần phải lấy tất cả các request content (và tự phân tích chúng).

Để lấy ra một chuối ký tự (string):

::

  val body = requestContentString

Để lấy ra một string và phân tích chúng thành JSON:

::

  val myJValue = requestContentJValue  // => JSON4S (http://json4s.org) JValue
  val myMap = xitrum.util.SeriDeseri.fromJValue[Map[String, Int]](myJValue)

Nếu bạn muốn kiểm soát toàn bộ, sử dụng `request.getContent <http://netty.io/4.0/api/io/netty/handler/codec/http/FullHttpRequest.html>`_. Nó sẽ trả về một `ByteBuf <http://netty.io/4.0/api/io/netty/buffer/ByteBuf.html>`_.

Viết tài liệu API với Swagger
----------------------------

Bạn có thể viết tài liệu cho API của bạn với `Swagger <https://developers.helloreverb.com/swagger/>`_. Thêm annotation ``@Swagger`` vào action cần được viết tài liệu.
Xitrum sẽ generate `/xitrum/swagger.json <https://github.com/wordnik/swagger-core/wiki/API-Declaration>`_.
Tệp này có thể sử dụng với `Swagger UI <https://github.com/wordnik/swagger-ui>`_ để tạo giao diện cho tài liệu của API.

Xitrum đã bao gồm Swagger UI. Sử dụng chúng tại đường dẫn ``/xitrum/swagger-ui` của chưong trình của bạn.
Ví dụ http://localhost:8000/xitrum/swagger-ui.

.. image:: ../img/swagger.png

Bạn có thể xem `một ví dụ <https://github.com/xitrum-framework/xitrum-placeholder>`_:

::

  import xitrum.{Action, SkipCsrfCheck}
  import xitrum.annotation.{GET, Swagger}

  @Swagger(
    Swagger.Tags("image", "APIs to create images"),
    Swagger.Description("Dimensions should not be bigger than 2000 x 2000"),
    Swagger.OptStringQuery("text", "Text to render on the image, default: Placeholder"),
    Swagger.Produces("image/png"),
    Swagger.Response(200, "PNG image"),
    Swagger.Response(400, "Width or height is invalid or too big")
  )
  trait ImageApi extends Action with SkipCsrfCheck {
    lazy val text = paramo("text").getOrElse("Placeholder")
  }

  @GET("image/:width/:height")
  @Swagger(  // <-- Inherits other info from ImageApi
    Swagger.Summary("Generate rectangle image"),
    Swagger.IntPath("width"),
    Swagger.IntPath("height")
  )
  class RectImageApi extends Api {
    def execute {
      val width  = param[Int]("width")
      val height = param[Int]("height")
      // ...
    }
  }

  @GET("image/:width")
  @Swagger(  // <-- Inherits other info from ImageApi
    Swagger.Summary("Generate square image"),
    Swagger.IntPath("width")
  )
  class SquareImageApi extends Api {
    def execute {
      val width  = param[Int]("width")
      // ...
    }
  }

`JSON cho Swagger <https://github.com/wordnik/swagger-spec/blob/master/versions/1.2.md>`_ sẽ được tạo khi bạn sử dụng ``/xitrum/swagger``.

Swagger UI sử dụng JSON dưới đây để tạo giao diện cho tài liệu API.

Ngoài các parameter như Swagger.IntPath và Swagger.OptStringQuery còn các tham số sau: BytePath, IntQuery, OptStringForm etc.
Chúng ta có thể tạo theo mẫu
They are in the form:

* ``<Value type><Param type>`` (required parameter)
* ``Opt<Value type><Param type>`` (optional parameter)

Kiểu dữ liệu: Byte, Int, Int32, Int64, Long, Number, Float, Double, String, Boolean, Date, DateTime

Kiểu tham số: Path, Query, Body, Header, Form

Đọc thêm về `kiểu dữ liệu <https://github.com/wordnik/swagger-core/wiki/Datatypes>`_ và  `kiểu tham số <https://github.com/wordnik/swagger-core/wiki/Parameters>`_.
