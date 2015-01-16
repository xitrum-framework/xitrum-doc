Giới thiệu
============

::

  +--------------------+
  |      Clients       |
  +--------------------+
            |
  +--------------------+
  |       Netty        |
  +--------------------+
  |       Xitrum       |
  | +----------------+ |
  | | HTTP(S) Server | |
  | |----------------| |
  | | Web framework  | |  <- Akka, Hazelcast -> Other instances
  | +----------------+ |
  +--------------------+
  |      Your app      |
  +--------------------+

Xitrum là một Scala web framework thống nhất, đồng bộ và HTTPS(server) dung hợp
trên nền của `Netty <http://netty.io/>`_ và `Akka <http://akka.io/>`_.

`Một người dùng Xiturm <https://groups.google.com/group/xitrum-framework/msg/d6de4865a8576d39>`_ đã nói rằng:

  Wow, đây thực sự là một sản phẩm tuyệt vời, có thể coi như một Scala framework
  hoàn chỉnh nhất ngoại trừ Lift (nhưng dễ sử dụng hơn nhiều).

  `Xitrum <http://xitrum-framework.github.io/>`_ một web framework `full-stack` đúng nghĩa, đáp ứng tất cả các 
  chức năng cơ bản của một web framework, bao gồm những phần mở rộng như ETags, file cache tĩnh, công cụ nén 
  Gzip tự động. Tích hợp công cụ chuyển đổi JSON, interceptor, các phạm vi request/session/cookie/flash, các bộ 
  chuẩn hóa tích hợp ở cả server và client, lớp cache tích hợp (`Hazelcast <http://www.hazelcast.org/>`_), 
  gettext, Netty (với Nginx), v.v . Và bạn có thể sử dụng những tiện ích trên ngay lập tức.

Tính năng
--------

* Viết code an toàn, dựa trên tinh thần của Scala. Tất cả các APIs đều được thiết kế an toàn nhất có thể
* Đồng bộ, theo tinh thần của Netty. Việc xử lý các yêu cầu (request) không cần phải đáp ứng(respond) ngay lập lức.
  Hỗ trợ kiểm soát vòng lớn, trả về(respond) theo đoạn (streaming), WebSocket, và SockJS.
* Thực hiện cài đặt nhanh chóng trên HTTP and HTTPS web server dựa trên `Netty <http://netty.io/>`_
  (HTTPS có thể sử dụng công nghệ Java hoặc công nghệ mã OpenSSL tự nhiên).
  Tốc độ phục vụ tập tin tĩnh của Xitrum có thể đạt mức`tương đương Nginx <https://gist.github.com/3293596>`_.
* Mở rộng quy mô hệ thống bộ nhớ cache ở phía máy chủ(server) và máy khách(client) để tăng tốc độ đáp ứng.
  Tại lớp máy chủ web, các tập tin nhỏ được lưu trữ trong bộ nhớ cache, tập tin lớn được gửi bằng kỹ thuật 
  zero copy của NIO. 
  Tại web framework bạn có thể khai báo trang, hành động và đối tượng bộ nhớ cache theo phong cách `Rails 
  framework <https://github.com/rails/rails>_'.
  `All Google's best practices <http://code.google.com/speed/page-speed/docs/rules_intro.html>`_
  như method GET có điều kiện được triển khai cho bộ nhớ cache phía client.
  Bạn cũng có thể buộc các trình duyệt để luôn gửi yêu cầu đến máy chủ để xác thực lại cache trước khi sử dụng.
* `Phạm vi yêu cầu <http://en.wikipedia.org/wiki/Byte_serving>`_ hỗ trợ các tập tin tĩnh. 
  Tính năng này cần cho việc cung cấp dịch vụ video cho điện thoại thông minh.
  Bạn có thể tạm dừng/tiếp tục việc tải tập tin.
* Hỗ trợ `CORS <http://en.wikipedia.org/wiki/Cross-origin_resource_sharing>`_.
* Việc định tuyến được thực hiện tự động trên tinh thần của JAX-RS và Rails Engines. 
  Bạn không cần phải được khai báo ở tất cả các tuyến kết nối cho mỗi điểm đơn lẻ.
  Hãy suy nghĩ về tính năng này như phân tuyến. Bạn có thể cài cắm ứng dụng này trong ứng dụng khác.
  Nếu bạn có một blog engine, bạn có thể đóng gói nó thành một tệp JAR và đặt tệp JAR đó trong một
  ứng dụng khác và ứng dụng đó sẽ tự động có tính năng của blog.
  Việc định tuyến thì bao gồm 2 cách: bạn có thể tái tạo đường dẫn URL (định tuyến đảo ngược) một cách an toàn.
  Bạn có thể dẫn chứng cho việc định tuyến bằng việc sử dụng `Swagger Doc <http://swagger.wordnik.com/>`_.
* Các lớp và các đường định tuyến được tải lại một cách tự động trong chế độ phát triển (development mode).
* Các View có thể viết bằng các tập tin mẫu `Scalate <http://scalate.fusesource.org/>`_
  một các riêng biệt hoặc bằng Scala inline XML. Cả hai cách đều an toàn.
* Phiên làm việc(Sessions) có thể lưu trữ ngay trong cookies(khả năng lưu trữ lớn hơn) hoặc lưu trữ bằng 
  `Hazelcast <http://www.hazelcast.org/>`_(tính bảo mật cao hơn).
  Hazelcast cũng cung cấp việc phân phối cache trong tiến trình (do đó nhanh hơn và dễ sử dụng hơn) ,
  vì vậy bạn không cần phải có một máy chủ cache riêng biệt. Điều này cũng đúng trong chức năng pubsub của Akka.
* `jQuery Validation <http://jqueryvalidation.org/>`_ được tích hợp trong việc chuẩn hóa dữ liệu ở cả máy chủ(server) và máy khách
  (client)
* i18n sử dụng `GNU gettext <http://en.wikipedia.org/wiki/GNU_gettext>`_.
  Việc khai thác các văn bản dịch được thực hiện tự động, bạn sẽ không cần bận tâm đến các thuộc tính của file.
  Bạn cũng có thể sử dụng các công cụ mạnh như `Poedit <http://www.poedit.net/screenshots.php>`_ để dịch và hợp nhất các bản dịch.
  gettext, không giống như hầu hết các giải pháp khác, hỗ trợ các định dạng của cả các thống thiểu số các hệ thống phổ biến hơn.

Xitrum cố gắng lấp đầy những khoảng trống giữa `Scalatra <https://github.com/scalatra/scalatra>`_
và `Lift <http://liftweb.net/>`_: mạnh hơn Scalatra và dễ sử dụng hơn Lift. Bạn có thể dễ dàng tạo cả RESTful APIS và postbacks.
`Xitrum <http://xitrum-framework.github.io/>`_ cũng là hệ thống controller-first như Scalatra, không phải là 
`view-first <http://www.assembla.com/wiki/show/liftweb/View_First>`_ như Lift.
Đa số mọi người đã quen thuộc với phong cách controller-first.

Hãy xem :doc:`các dự án liên quan </deps>` để có được danh sách các bản demos, plugins v.v.

Đóng góp
------------

`Xitrum <http://xitrum-framework.github.io/>`_ là một framework mã nguồn mở, mã nguồn của Xitrum có thể tìm thấy 
`ở đây <https://github.com/xitrum-framework/xitrum>`_,
bạn có thể tham gia vào `Google group <http://groups.google.com/group/xitrum-framework>`_ của chúng tôi.

Những người đóng góp dưới đây được liệt kê theo thứ tự 
`đóng góp đầu tiên của họ <https://github.com/xitrum-framework/xitrum/graphs/contributors>`_.

(*): Hiện tại là thành viên hoạt động chính.

* `Ngoc Dao (*) <https://github.com/ngocdaothanh>`_
* `Linh Tran <https://github.com/alide>`_
* `James Earl Douglas <https://github.com/earldouglas>`_
* `Aleksander Guryanov <https://github.com/caiiiycuk>`_
* `Takeharu Oshida (*) <https://github.com/georgeOsdDev>`_
* `Nguyen Kim Kha <https://github.com/kimkha>`_
* `Michael Murray <https://github.com/murz>`_
