Кэш на стороне сервера
======================

Так же смотри главу про :doc:`кластеризацию </cluster>`.

Xitrum предоставляет широкие возможности для кэширования на стороне клиента и сервера.
На уровне веб сервера, маленькие файлы кэшируются в памяти, большие отправляются по 
технологии zero copy. Скорость отдачи статических файлов сравнима с
`Nginx <https://gist.github.com/3293596>`_.
На уровне фреймворка вы можете использовать кэш страницы, кэш контроллера или объектный кэш в
стиле Rails.
Xitrum придерживается `рекомендации Google <http://code.google.com/speed/page-speed/docs/rules_intro.html>`_.

Для динамического контента, если контент не меняется после создания (как в случае статического
файла), вы можете установить необходимые заголовки для агрессивного кэширования. В этом
случае используйте метод ``setClientCacheAggressively()`` в контроллере.

Иногда требуется запретить кэширование на стороне клиента. В этом случае используйте
``setNoClientCache()`` в контроллере.

Кэширование на стороне сервера более подробно рассматривается ниже.

Кэширование страницы или контроллера
------------------------------------

::

  import xitrum.Action
  import xitrum.annotation.{GET, CacheActionMinute, CachePageMinute}

  @GET("articles")
  @CachePageMinute(1)
  class ArticlesIndex extends Action {
    def execute() {
      ...
    }
  }

  @GET("articles/:id")
  @CacheActionMinute(1)
  class ArticlesShow extends Action {
    def execute() {
      ...
    }
  }

Термин "кэш страницы" и "кэш контроллера" позаимствован из 
`Ruby on Rails <http://guides.rubyonrails.org/caching_with_rails.html>`_.

Последовательность обработки запроса следующая:
(1) запрос -> (2) пре-фильтры -> (3) метод execute контроллера -> (4) ответ

После первого запроса, Xitrum закеширует ответ на указанный период времени.
``@CachePageMinute(1)`` или ``@CacheActionMinute(1)`` задают время кэша равное одной минуте.
Xitrum кэширует страницы только в случае если ответ имеет статус "200 OK". Например, ответ
со статусом "500 Internal Server Error" или "302 Found" (redirect) не будет помещен в кэш.

В случае запросов к тому же контроллеру, если кэш еще не устарел, Xitrum в качестве
ответа будет использовать значение из кэша:

* Для кэша страницы, последовательность обработки (1) -> (4).
* Для кэша контроллера, последовательность обработки (1) -> (2) -> (4), или просто (1) -> (2)
  если пре-фильтр вернет значение "false".

Единственное различие: для кэша страницы пре-фильтры не запускаются.

Обычно, кэш страницы используется когда один и тот же ответ подходит для всех пользователей.
Кэш контроллера используется когда вам нужно использовать пре-фильтр как защиту, например
для проверки авторизации пользователя:

* Если пользователь прошел авторизацию, он может получать кэшированный ответ.
* Если нет, отправить пользователя на страницу авторизации.

Кэш объект
----------

Кэширующие методы предоставляются объектом ``xitrum.Config.xitrum.cache``, наследником
`xitrum.Cache <http://xitrum-framework.github.io/api/index.html#xitrum.Cache>`_.

Без указания TTL (времени жизни):

* put(key, value)

С указанием TTL:

* putSecond(key, value, seconds)
* putMinute(key, value, minutes)
* putHour(key, value, hours)
* putDay(key, value, days)

Обновление кэша только в случае отсутствия значения:

* putIfAbsent(key, value)
* putIfAbsentSecond(key, value, seconds)
* putIfAbsentMinute(key, value, minutes)
* putIfAbsentHour(key, value, hours)
* putIfAbsentDay(key, value, days)

Удаление кэша
-------------

Удаление кэша страницы или контроллера:

::

  removeAction[MyAction]

Удаление объектного кэша:

::

  remove(key)

Удаление всех ключей начинающихся с префикса:

::

  removePrefix(keyPrefix)

При использовании ``removePrefix``, вы можете организовать иерархический кэш. Например, вы можете
создавать кэш связанной со статьей, а когда статья изменится просто удалите весь кэш статьи.

::

  import xitrum.Config.xitrum.cache

  // Кэш с префиксом
  val prefix = "articles/" + article.id
  cache.put(prefix + "/likes", likes)
  cache.put(prefix + "/comments", comments)

  // Позднее, очистка кэша
  cache.remove(prefix)

Конфигурация
------------

Вы можете использовать свою реализацию кэша.

В файле `config/xitrum.conf <https://github.com/xitrum-framework/xitrum-new/blob/master/config/xitrum.conf>`_,
вы можете настроить кэш двумя способами:

::

  cache = my.cache.EngineClassName

Или:

::

  cache {
    "my.cache.EngineClassName" {
      option1 = value1
      option2 = value2
    }
  }

Xitrum предоставляет реализацию по умолчанию:

::

  cache {
    # Simple in-memory cache
    "xitrum.local.LruCache" {
      maxElems = 10000
    }
  }

Если вы используете кластер, вы можете использовать `Hazelcast <https://github.com/xitrum-framework/xitrum-hazelcast>`_.

Для создания своей реализации кэша, реализуйте интерфейс `interface <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/Cache.scala>`_
``xitrum.Cache``.

Как работает кэш
----------------

Вход:

::

                 ответ контроллера   
                 должен быть в кэше  
  запрос         и кэш существует?        
  -------------------------+---------------НЕТ-------------->
                           |
  <---------ДА-------------+
    ответ из кэша     


Выход:

::

                 ответ контроллера   
                 должен быть помещен в кэш
                 кэш не существует?                     ответ
  <---------НЕТ------------+---------------------------------
                           |
  <---------ДА-------------+
    сохранить ответ в кэше 

xitrum.util.LocalLruCache
-------------------------

Этот кэш переиспользуется всеми компонентами Xitrum. Если вам нужен отдельный небольшой
кэш, вы можете использовать ``xitrum.util.LocalLruCache``.

::

  import xitrum.util.LocalLruCache

  // LRU (Least Recently Used) кэш содержит до 1000 элементов.
  // Ключи и значения имеет тип String.
  val cache = LocalLruCache[String, String](1000)

Переменная  ``cache`` имеет тип `java.util.LinkedHashMap <http://docs.oracle.com/javase/6/docs/api/java/util/LinkedHashMap.html>`_. Вы можете использовать методы из ``LinkedHashMap``.
