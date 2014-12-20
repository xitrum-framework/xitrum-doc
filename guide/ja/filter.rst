アクションフィルター
====================

Beforeフィルター
----------------

Beforeフィルターが関数でアクションの実行前に実行されます。

* 入力: なし
* 出力: true/false

Beforeフィルターを複数設定できます。その中、ーつのbeforeフィルターが何かrespondするとき、その
フィルターの後ろのフィルターとアクションの実行が中止されます。

::

  import xitrum.Action
  import xitrum.annotation.GET

  @GET("before_filter")
  class MyAction extends Action {
    beforeFilter {
      log.info("我行くゆえに我あり")
    }

    // This method is run after the above filters
    def execute() {
      respondInlineView("Beforeフィルターが実行されました。ログを確認してください。")
    }
  }

Afterフィルター
---------------

Afterフィルターが関数でアクションの実行後に実行されます。

* 入力: なし
* 出力: 無視されます

::

  import xitrum.Action
  import xitrum.annotation.GET

  @GET("after_filter")
  class MyAction extends Action {
    afterFilter {
      log.info("実行時刻: " + System.currentTimeMillis())
    }

    def execute() {
      respondText("Afterフィルターが実行されました。ログを確認してください。")
    }
  }

Aroundフィルター
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

Aroundフィルターが複数あるとき、それらは外・内の構成でネストされます。

フィルターの実行順番
--------------------

* Beforeフィルター -> aroundフィルター -> afterフィルター。
* あるbeforeフィルタがfalseを返すと、残りフィルターが実行されません。
* Aroundフィルターが実行されると、すべてのafterフィルター実行されます。
* 外のaround filterフィルターが ``action`` 引数を呼ばないと、内のaroundフィルターが実行されません。

::

  before1 -true-> before2 -true-> +--------------------+ --> after1 --> after2
                                  | around1 (1 of 2)   |
                                  |   around2 (1 of 2) |
                                  |     action         |
                                  |   around2 (2 of 2) |
                                  | around1 (2 of 2)   |
                                  +--------------------+
