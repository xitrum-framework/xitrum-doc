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

Xitrum là một Scala web framework bất đồng bộ, `clustered` và cũng là một HTTPS(server) trên nền của 
`Netty <http://netty.io/>`_ và `Akka <http://akka.io/>`_.

`Một người dùng Xiturm <https://groups.google.com/group/xitrum-framework/msg/d6de4865a8576d39>`_ đã nói rằng:

  Wow, đây thực sự là một sản phẩm tuyệt vời, có thể coi như một Scala framework
  hoàn chỉnh tới mức có thể so sánh với Lift (nhưng dễ sử dụng hơn nhiều).

  `Xitrum <http://xitrum-framework.github.io/>`_ một web framework `full-stack` đúng nghĩa, đáp ứng tất cả các 
  chức năng cơ bản của một web framework, ngoài ra còn có những phần mở rộng như ETags, file cache tĩnh, công cụ nén 
  Gzip tự động. Tích hợp công cụ chuyển đổi JSON, before/around/after interceptors, request/session/cookie/flash scopes, 
  các bộ chuẩn hóa input tích hợp ở cả server và client, tích hợp cả tính năng cache (`Hazelcast <http://www.hazelcast.org/>`_), 
  tính năng đa ngôn ngữ i18n theo phong cách GNU gettext, Netty (nhanh không kém Nginx), v.v . Và bạn có thể sử dụng nhiều tính năng khác nữa.

Tính năng
--------

* Typesafe, dựa trên tinh thần của Scala. Tất cả các APIs đều được thiết kế an toàn nhất có thể
* Bất đồng bộ, theo tinh thần của Netty. Việc xử lý các yêu cầu (request) không cần phải đáp ứng (respond) ngay lập lức.
  Long polling, chunked response (streaming), WebSocket, và SockJS.
* Tích hợp sẵn HTTP và HTTPS server có tốc độ nhanh dựa trên `Netty <http://netty.io/>`_
  (HTTPS có thể sử dụng công nghệ Java hoặc công nghệ mã OpenSSL tự nhiên).
  Tốc độ phục vụ tập tin tĩnh của Xitrum có thể đạt mức `tương đương Nginx <https://gist.github.com/3293596>`_.
* Tối ưu hóa cache cả ở phía máy chủ (server) và máy khách (client) để tăng tốc độ đáp ứng.
  Ở tầng máy chủ web, các tập tin nhỏ được cache vào bộ nhớ, đối với các tập tin lớn thì sử dụng kỹ thuật 
  zero copy của NIO. 
  Ở tầng web framework bạn có thể khai báo cache ở các mức page, action và object theo phong cách `Rails framework 
  <https://github.com/rails/rails>`_.
  `Tất cả thủ thuật mà Google khuyên nên dùng để tăng tốc trang web <http://code.google.com/speed/page-speed/docs/rules_intro.html>`_ 
  như method GET có điều kiện được áp dụng để cache phía client.
  Bạn cũng có thể buộc các trình duyệt để luôn gửi yêu cầu đến máy chủ để kiểm tra lại cache trước khi sử dụng.
* Tính năng `range request <http://en.wikipedia.org/wiki/Byte_serving>`_ hỗ trợ các tập tin tĩnh. 
  Tính năng này cần cho việc cung cấp dịch vụ video cho điện thoại thông minh.
  Bạn có thể tạm dừng/tiếp tục việc tải tập tin video.
* Hỗ trợ `CORS <http://en.wikipedia.org/wiki/Cross-origin_resource_sharing>`_.
* Tính năng định tuyến được thực hiện tự động trên tinh thần của JAX-RS và Rails Engines. 
  Bạn không cần phải được khai báo ở tất cả các tuyến kết nối tại cùng một điểm mà có thể tại nhiều điểm khác nhau.
  Tính năng này có thể hiểu như định tuyến một cách phân tán. Bạn có thể cài cắm ứng dụng này vào ứng dụng khác.
  Nếu bạn có một blog engine, bạn có thể đóng gói nó thành một tập tin JAR và đặt tập tin JAR đó trong một
  ứng dụng khác, với cách làm như vậy ứng dụng đó sẽ có thêm tính năng blog.
  Việc định tuyến thì bao gồm 2 chiều: bạn có thể tái tạo đường dẫn URL (reverse routing) một cách an toàn từ action.
  Bạn có thể tạo tài liệu về các định tuyến bằng cách sử dụng `Swagger Doc <http://swagger.wordnik.com/>`_.
* Các lớp và các đường định tuyến được tải lại một cách tự động trong chế độ phát triển (development mode).
* Các View có thể viết bằng các tập tin mẫu `Scalate <http://scalate.fusesource.org/>`_
  một các riêng biệt hoặc bằng Scala inline XML. Cả hai cách đều an toàn.
* Phiên làm việc(Sessions) có thể lưu trữ ngay trong cookies(đáp ứng đuợc nhiều user cùng lúc hơn) hoặc lưu trữ bằng `Hazelcast <http://www.hazelcast.org/>`_ (tính bảo mật cao hơn).
  Hazelcast cũng chạy ngay trong cùng process với việc sử dụng cache phân tán(do đó nhanh hơn và dễ sử dụng hơn) ,
  vì vậy bạn không cần phải có một máy chủ cache riêng biệt. Điều này cũng đúng trong chức năng pubsub của Akka.
* `jQuery Validation <http://jqueryvalidation.org/>`_ được tích hợp trong việc chuẩn hóa dữ liệu ở cả máy chủ(server) và máy khách
  (client)
* i18n theo phong cách `GNU gettext <http://en.wikipedia.org/wiki/GNU_gettext>`_.
  Việc trích các chuổi văn bản ra ngoài để thực hiện dịch được thực hiện tự động, bạn sẽ không cần làm thủ công với properties file.
  Bạn cũng có thể sử dụng các công cụ mạnh như `Poedit <http://www.poedit.net/screenshots.php>`_ để dịch và hợp nhất các bản dịch.
  gettext, không giống như hầu hết các giải pháp khác, hỗ trợ các định dạng của cả số ít và số nhiều.

Xitrum cố gắng khắc phục các nhược điểm của `Scalatra <https://github.com/scalatra/scalatra>`_
và `Lift <http://liftweb.net/>`_: mạnh hơn Scalatra và dễ sử dụng hơn Lift. Bạn có thể dễ dàng tạo cả RESTful APIs và postbacks.
`Xitrum <http://xitrum-framework.github.io/>`_ là hệ thống controller-first như Scalatra, không phải là 
`view-first <http://www.assembla.com/wiki/show/liftweb/View_First>`_ như Lift.
Đa số mọi người đã quen thuộc với phong cách controller-first.

Hãy xem :doc:`các dự án liên quan </deps>` để có được danh sách các bản demos, plugins v.v.

Đóng góp
------------

`Xitrum <http://xitrum-framework.github.io/>`_ là một framework mã nguồn mở, mã nguồn của Xitrum có thể tìm thấy 
`tại đây <https://github.com/xitrum-framework/xitrum>`_,
bạn có thể tham gia vào `Google group <http://groups.google.com/group/xitrum-framework>`_ của chúng tôi.

Những người đóng góp dưới đây được xếp theo thứ tự 
`đóng góp đầu tiên của họ <https://github.com/xitrum-framework/xitrum/graphs/contributors>`_.

(*): Hiện tại là thành viên hoạt động chính.

* `Ngoc Dao (*) <https://github.com/ngocdaothanh>`_
* `Linh Tran <https://github.com/alide>`_
* `James Earl Douglas <https://github.com/earldouglas>`_
* `Aleksander Guryanov <https://github.com/caiiiycuk>`_
* `Takeharu Oshida (*) <https://github.com/georgeOsdDev>`_
* `Nguyen Kim Kha <https://github.com/kimkha>`_
* `Michael Murray <https://github.com/murz>`_
