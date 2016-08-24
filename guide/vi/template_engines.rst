Template engines
================

Template engine đã được cấu hình sẽ được gọi khi :doc:`renderView, renderFragment,
hoặc respondView </action_view>` được gọi tới.

Cấu hình template engine
------------------------

Trong tệp `config/xitrum.conf <https://github.com/xitrum-framework/xitrum-new/blob/master/config/xitrum.conf>`_, template engine có thể cấu hình theo 2 mẫu dưới dây, phụ thuộc vào engine mà bạn sử dụng:

::

  template = my.template.EngineClassName

Hoặc:

::

  template {
    "my.template.EngineClassName" {
      option1 = value1
      option2 = value2
    }
  }

Template engine mặc định là `xitrum-scalate <https://github.com/xitrum-framework/xitrum-scalate>`_.

Xóa template engine
-------------------

Nếu bạn chỉ tạo RESTful APIs trong project, thông thường bạn không sử dụng method renderView, renderFragment, hoặc respondView. Trong trường hợp này, bạn còn có thể xóa template engine khỏi project để project nhẹ hơn. Bạn chỉ cần xóa hoặc comment dòng ``templateEngine`` trong tệp config/xitrum.conf.

Sau đó bạn xóa các cấu hình template liên quan khỏi project của bạn.

Tự tạo template engine cho riêng bạn
------------------------------------

Để tạo template engine cho riêng bạn, tạo một class kế thừa từ `xitrum.view.TemplateEngine <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/view/TemplateEngine.scala>`_.
Và đặt class này của bạn trong tệp config/xitrum.conf.

Ví dụ, xem `xitrum-scalate <https://github.com/xitrum-framework/xitrum-scalate>`_.
