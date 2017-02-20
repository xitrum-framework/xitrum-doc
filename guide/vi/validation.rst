Validation
==========

Xitrum bao gồm `jQuery Validation plugin <http://bassistance.de/jquery-plugins/jquery-plugin-validation/>`_
để kiểm tra kiểu ở phía client và cung cấp các bộ kiểm tra kiểu cho phía server.

Validator mặc định
------------------

Xitrum cung cấp sẵn validator trong package ``xitrum.validator``.
Chúng có những hàm sau: 

::

  check(value): Boolean
  message(name, value): Option[String]
  exception(name, value)

Nếu validation báo lỗi, hàm ``message`` sẽ trả về ``Some(error message)``,
hàm ``exception`` sẽ throw ``xitrum.exception.InvalidInput(error message)``.

Bạn có thể sử dụng validator bất cứ đâu.

Ví dụ action:

::

  import xitrum.validator.Required

  @POST("articles")
  class CreateArticle {
    def execute() {
      val title = param("tite")
      val body  = param("body")
      Required.exception("Title", title)
      Required.exception("Body",  body)

      // Làm gì đó với title và body đúng...
    }
  }

Nếu không sử dụng ``try`` và ``catch``, khi có lỗi trong quá trình validation 
(not pass), Xitrum sẽ tự động ``catch`` các exception và respond thông báo lỗi 
về phía client. Điều này giúp cho việc viết các web API hoặc sử dụng validation 
ở phía client tiện lợi hơn. 

Ví dụ model:

::

  import xitrum.validator.Required

  case class Article(id: Int = 0, title: String = "", body: String = "") {
    def isValid           = Required.check(title)   &&     Required.check(body)
    def validationMessage = Required.message(title) orElse Required.message(body)
  }

Xem `package xitrum.validator <https://github.com/xitrum-framework/xitrum/tree/master/src/main/scala/xitrum/validator>`_ để có đầy đủ các validator mặc định.

Tạo một validator
-----------------

Kế thừa `xitrum.validator.Validator <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/validator/Validator.scala>`_.
Bạn chỉ phải implement 2 method ``check`` và ``message``.

Bạn cũng có thể sử dụng `Commons Validator <http://commons.apache.org/proper/commons-validator/>`_.
