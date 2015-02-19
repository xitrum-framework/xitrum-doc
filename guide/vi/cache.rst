Cache ở server
==============

Cũng có thể xem phần nói về :doc:`clustering </cluster>`.

Tối ưu hóa cache cả ở phía máy chủ (server) và máy khách (client) để tăng tốc độ đáp ứng.
Ở tầng máy chủ web, các tập tin nhỏ được cache vào bộ nhớ, đối với các tập tin lớn thì sử dụng kỹ thuật 
zero copy của NIO. . Các tệp tĩnh trong xitrum được
cung cấp với tốc độ `tương đương với Nginx <https://gist.github.com/3293596>`_.
Tại lớp web framework, bạn có thể khai báo cache ở mức page, action và object với 
phong cách `Rails framework <https://github.com/rails/rails>`_.

`Tất cả thủ thuật mà Google khuyên nên dùng để tăng tốc trang web <http://code.google.com/speed/page-speed/docs/rules_intro.html>`_ 
như method GET có điều kiện được áp dụng để cache phía client.

Với các nội dung động (dynamic content), nếu content không đổi sau khi được tạo 
(như một tệp tĩnh), bạn có thể cần đặt header để được lưu trữ một cách chủ động
ở phía client. Trong trường hợp này, sử dụng ``setClientCacheAggressively()`` trong
Action.

Ngược lại, đôi khi bạn có thể không muốn cache ở phía client, bạn sử dụng method
``setNoClientCache()`` trong action.

Cache ở phía server sẽ được trình bày chi tiết dưới dây.

Cache ở mức page hoặc action
----------------------------

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

Thuật ngữ "page cache" và "action cache" bắt nguồn từ
`Ruby on Rails <http://guides.rubyonrails.org/caching_with_rails.html>`_.

Thứ tự thực thi một request được thiết kế như sa:
(1) request -> (2) các method before filter -> (3) các method thực thi action -> (4) response

Ở request đầu tiên, Xitrum sẽ cache response trong một thời gian sống xác đinh.
``@CachePageMinute(1)`` hoặc ``@CacheActionMinute(1)`` đều có nghĩa là cache 
trong 1 phút.
Xitrum chỉ cache khi response có trạng thái "200 OK". Ví dụ, response với trạng
thái "500 Internal Server Error" hoặc "302 Found" (direct) sẽ không được cache.

Ở các request sau đến cùng một action, nếu response đã được cache vẫn nằm trong thời
gian sống xác định bên trên, Xitrum sẽ chỉ respond chính response đã được cache.

* Với page cache, thứ tự thực hiện là (1) -> (4).
* Với action cache, thứ tự thực hiện là (1) -> (2) -> (4), hoặc chỉ là (1) -> (2)
  nếu một trong những before filter trả về "false".

Sự khác biệt giữa 2 loại cache: với page cache, các before filter sẽ không chạy.

Thông tường, page cache thường được sử dụng khi các response giống nhau được gửi 
đến tất cả người dùng.
Action cache được sử dụng khi bạn muốn chạy một before filter để "guard" (bảo vệ)
response đã được cache, giống như việc kiểm ra người dùng đã đăng nhập hay chưa:

* Nếu người dùng đã đăng nhập, họ có thể sử dụng response đã được cache.
* Nếu người dùng chưa thực hiện đăng nhập, redirect họ đến trang đăng nhập.

Cache ở mức object
------------------

Bạn sử dụng method trong ``xitrum.Config.xitrum.cache``, nó là một instance của
`xitrum.Cache <http://xitrum-framework.github.io/api/3.17/index.html#xitrum.Cache>`_.

Không có một TTL(time to live - thời gian sống) rõ rõ ràng:

* put(key, value)

Với một TTL(time to live - thời gian sống) rõ rõ ràng: 

* putSecond(key, value, seconds)
* putMinute(key, value, minutes)
* putHour(key, value, hours)
* putDay(key, value, days)

Only if absent:

* putIfAbsent(key, value)
* putIfAbsentSecond(key, value, seconds)
* putIfAbsentMinute(key, value, minutes)
* putIfAbsentHour(key, value, hours)
* putIfAbsentDay(key, value, days)

Xóa cache
---------

Xóa "page cache" và "action cache":

::

  removeAction[MyAction]

Xóa "object cache":

::

  remove(key)

Xóa tất cả các khóa bắt đầu với một prefix:

::

  removePrefix(keyPrefix)

Với ``removePrefix``, bạn có thể kế thừa form cache trong prefix.
Ví dụ bạn muốn cache những thứ liên quan đến một article, sau khi article thay đổi,
bạn muốn xóa tất cả những thứ đó.

::

  import xitrum.Config.xitrum.cache

  // Cache với một prefix
  val prefix = "articles/" + article.id
  cache.put(prefix + "/likes", likes)
  cache.put(prefix + "/comments", comments)

  // Sau đó, khi xảy ra 1 sự kiện nào đó, và bạn muốn xóa tất cả các cache liên 
  //quan đến artical 
  cache.remove(prefix)

Config
------

Tính năng cache trong Xitrum được cung cấp bởi các cache engine. Bạn có thể chọn 
engine phù hợp với yếu cầu của bạn.

Trong `config/xitrum.conf <https://github.com/xitrum-framework/xitrum-new/blob/master/config/xitrum.conf>`_,
bạn có thể cấu hình cache engine tại 1 trong 2 form sau, phụ thuộc vào engine bạn
chọn:

::

  cache = my.cache.EngineClassName

Or:

::

  cache {
    "my.cache.EngineClassName" {
      option1 = value1
      option2 = value2
    }
  }

Xitrum cung cấp:

::

  cache {
    # Simple in-memory cache
    "xitrum.local.LruCache" {
      maxElems = 10000
    }
  }

Nếu bạn có một cụm máy chủ, bạn có thể sử dụng `Hazelcast <https://github.com/xitrum-framework/xitrum-hazelcast>`_.

Nếu bạn muốn tạo cache engine cho riêng bạn, implement 
`interface <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/Cache.scala>`_
``xitrum.Cache``.

Cache hoạt động như thế nào
---------------------------

Inbound:

::

                 action response nên được
                 cache và cache đã tồn tại
  request        trước đó?
  -------------------------+---------------NO--------------->
                           |
  <---------YES------------+
    respond từ cache


Outbound:

::

                 action response nên được
                 cache và cache chưa tồn tại
                 trước đó?                           response
  <---------NO-------------+---------------------------------
                           |
  <---------YES------------+
    lưu response vào cache

xitrum.util.LocalLruCache
-------------------------

Cache trên đây là cache chia sẻ bởi toàn bộ hệ thống. Nếu bạn muốn cache ở trong 
một phạm vi nhỏ, bạn có thể sử dụng ``xitrum.util.LocalLruCache``.

::

  import xitrum.util.LocalLruCache

  // LRU (Least Recently Used) cache that can contain 1000 elements.
  // Keys and values are both of type String.
  val cache = LocalLruCache[String, String](1000)

``cache`` đã được trả về là một `java.util.LinkedHashMap <http://docs.oracle.com/javase/6/docs/api/java/util/LinkedHashMap.html>`_.
Bạn có thể sử dụng method ``LinkedHashMap`` từ nó.
