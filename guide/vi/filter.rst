Bộ lọc (filter) trong Action
============================

Before filters
--------------

Before filters chạy trước khi action chạy.
Nếu một before filter respond bất kì thứ gì, tất cả các filter sau đó và cả action 
sẽ không chạy.

::

  import xitrum.Action
  import xitrum.annotation.GET

  @GET("before_filter")
  class MyAction extends Action {
    beforeFilter {
      log.info("I run therefore I am")
    }

    // Method này chạy sau filter bên trên
    def execute() {
      respondInlineView("Before filters should have been run, please check the log")
    }
  }

After filters
-------------

Before filters chạy sau khi action chạy.
Chúng là các hàm (function) không tham số. Các giá trị trả về của các hàm này
sẽ bị từ chối.

::

  import xitrum.Action
  import xitrum.annotation.GET

  @GET("after_filter")
  class MyAction extends Action {
    afterFilter {
      log.info("Run at " + System.currentTimeMillis())
    }

    def execute() {
      respondText("After filter should have been run, please check the log")
    }
  }

Around filters
---------------

::

  import xitrum.Action
  import xitrum.annotation.GET

  @GET("around_filter")
  class MyAction extends Action {
    aroundFilter { action =>
      val begin = System.currentTimeMillis()
      action()
      val end   = System.currentTimeMillis()
      val dt    = end - begin
      log.info(s"The action took $dt [ms]")
    }

    def execute() {
      respondText("Around filter should have been run, please check the log")
    }
  }

Nếu có nhiều around filter, chúng sẽ lồng nhau.

Thứ tự thực hiện của các bộ lọc (filter)
----------------------------------------

* Before filters được chạy đầu tiên, sau đó là  around filter, cuối cùng là after 
filter.
* Néu một trong nhưng before filter trả về false, các filter con lại ( bao gồm 
around và after filter) sẽ không được chạy.
* After filters luôn được chạy nếu ít nhát có một around filter được chạy.
* Nếu một around filter không gọi ``action``, các around filter lồng bên trong 
filter này sẽ không được chạy.

::

  before1 -true-> before2 -true-> +--------------------+ --> after1 --> after2
                                  | around1 (1 of 2)   |
                                  |   around2 (1 of 2) |
                                  |     action         |
                                  |   around2 (2 of 2) |
                                  | around1 (2 of 2)   |
                                  +--------------------+
