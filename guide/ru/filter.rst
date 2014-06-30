Фильтры
=======

Пре-фильтр (before filter)
--------------------------

Данные фильтры запускаются до того как контроллер начнет обработку запроса.
Они не принимают входных параметров и возвращают true или false. Если
пре-фильтр возвращает false, все остальные фильтры и сам контроллер не будет
запущен.

::

  import xitrum.Action
  import xitrum.annotation.GET

  @GET("before_filter")
  class MyAction extends Action {
    beforeFilter {
      log.info("I run therefore I am")
      true
    }

    // метод выполнится после всех фильтров
    def execute() {
      respondInlineView("Пре-фильтр должны быть выполнен, проверьте лог")
    }
  }

Пост-фильтры (after filter)
--------------------------

Пост-фильтры запускаются после выполнения контроллера.
Они не принимают аргументов и не возвращают значений.

::

  import xitrum.Action
  import xitrum.annotation.GET

  @GET("after_filter")
  class MyAction extends Action {
    afterFilter {
      log.info("Время запуска " + System.currentTimeMillis())
    }

    def execute() {
      respondText("Пост-фильтр должен будет запустится, проверьте лог")
    }
  }

Внешние фильтры (around filter)
-------------------------------

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
      log.info(s"Контролер выполнялся $dt [ms]")
    }

    def execute() {
      respondText("Внешний фильтр должен выполниться, проверьте лог")
    }
  }

Если внешних фильтров будет несколько, они будут вложены друг в друга.

Порядок выполнения фильтров
---------------------------

* Вначале выполняются пре-фильтры, затем внешние фильтры, и последними выполняются пост-фильтры.
* Если пре-фильтр возвращает false, остальные фильтры (включая внешние и пост-фильтры) не будут запущены.
* Пост-фильтры выполняются, в том числе, если хотя бы один из внешних фильтров выполнился.
* Если внешний фильтр не вызывает ``action``, вложенные внешние фильтры не будут выполнены.

::

  before1 -true-> before2 -true-> +--------------------+ --> after1 --> after2
                                  | around1 (1 of 2)   |
                                  |   around2 (1 of 2) |
                                  |     action         |
                                  |   around2 (2 of 2) |
                                  | around1 (2 of 2)   |
                                  +--------------------+
