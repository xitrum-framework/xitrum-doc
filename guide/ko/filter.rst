액션 필터
====================

Before 필터
----------------

Before필터는 액션이 수행되기 전에 수행됩니다
만약 Before가 무언가를 응답한다면, 필터 이후의 어떠한 액션도 수행되지 않습니다

::

  import xitrum.Action
  import xitrum.annotation.GET

  @GET("before_filter")
  class MyAction extends Action {
    beforeFilter {
      log.info("I run therefore I am")
    }

    // This method is run after the above filters
    def execute() {
      respondInlineView("Before filters should have been run, please check the log")
    }
  }

After필터
---------------

After필터는 액션이 수행되고 난 후에 수행됩니다
함수들은 입력값이 없으면, 리턴값은 무시됩니다

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

Around필터 
----------------

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
      log.info(s"アクション実行時間: $dt [ms]")
    }

    def execute() {
      respondText("Around filter should have been run, please check the log")
    }
  }

Around필터가 여러개 있을때, 외부, 내부구성에 중첩됩니다

필터의 수행 순서
------------

* Before 필터 -> around 필터 -> after 필터.
* 몇몇 before 필터가 false를 반환하면 나머지 필터가 실행되지 않습니다.
* Around 필터가 실행되면 모든 after 필터가 실행됩니다.
* 외부 around filter 필터가``action`` 인수를 호출하지 않으면 내부의 around 필터가 실행되지 않습니다.

::

  before1 -true-> before2 -true-> +--------------------+ --> after1 --> after2
                                  | around1 (1 of 2)   |
                                  |   around2 (1 of 2) |
                                  |     action         |
                                  |   around2 (2 of 2) |
                                  | around1 (2 of 2)   |
                                  +--------------------+
