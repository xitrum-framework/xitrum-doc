Triển khai ứng dụng web trên server
===================================

Bạn có thể chạy trực tiếp Xitrum:

::

  Browser ------ Xitrum instance

Hoăc behind a load balancer như HAProxy, hoặc reverse proxy như Apache hay Nginx:

::

  Browser ------ Load balancer/Reverse proxy -+---- Xitrum instance1
                                              +---- Xitrum instance2

Đóng gói thư mục
---------------

Chạy ``sbt/sbt xitrum-package`` để chuẩn bị cho thư mục ``target/xitrum`` sẵn sàng
triển khai tại server sản phẩm:

::

  target/xitrum
    config
      [config files]
    public
      [static public files]
    lib
      [dependencies and packaged project file]
    script
      runner
      runner.bat
      scalive
      scalive.jar
      scalive.bat

Customize xitrum-package
------------------------

Mặc định câu lệnh ``sbt/sbt xitrum-package`` được cấu hình để sao chép các thư mục
``config``, ``public``, và ``script`` đến ``target/xitrum``. Nếu bạn muốn câu lệnh
đó sao chép các thư mục hoặc tệp khác sửa tệp ``build.sbt`` như sau:

::

  XitrumPackage.copy("config", "public, "script", "doc/README.txt", "etc.")

Xem `xitrum-package homepage <https://github.com/xitrum-framework/xitrum-package>`_
để biết thêm chi tiết.

Kết nối Scala console đến một tiến trình JVM đang chạy
------------------------------------------------------

Trong môi trường sản phẩm (production environment), nếu không có khởi tạo, bạn có
thể sử dụng `Scalive <https://github.com/xitrum-framework/scalive>`_
để kết nối một Scala console đến một tiến trình JVM đang chạy để gỡ lỗi trực tiếp.

Chạy ``scalive`` trong thư mục script:

::

  script
    runner
    runner.bat
    scalive
    scalive.jar
    scalive.bat

Cài đặt Oracle JDK trên CentOS hoặc Ubuntu
------------------------------------------

Dưới đây là hướng dẫn một cách đơn giản để cài đặt Java.Bạn có thể
cài đặt Java bằng cách sử dụng trình quản lý gói.

Kiểm tra các phiên bản Java đã được cài đặt:

::

  sudo update-alternatives --list java

Ví dụ output:

::

  /usr/lib/jvm/jdk1.7.0_15/bin/java
  /usr/lib/jvm/jdk1.7.0_25/bin/java

Kiểm tra môi trường (32 bit hay 64 bit):

::

  file /sbin/init

Ví dụ output:

::

  /sbin/init: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.24, BuildID[sha1]=0x4efe732752ed9f8cc491de1c8a271eb7f4144a5c, stripped

Tải JDK từ `Oracle <http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html>`_.
Đây là một `thủ thuật <http://stackoverflow.com/questions/10268583/how-to-automate-download-and-instalation-of-java-jdk-on-linux>`_
để tải jdk mà không dùng trình duyệt:

::

  wget --no-cookies --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com" "http://download.oracle.com/otn-pub/java/jdk/7u45-b18/jdk-7u45-linux-x64.tar.gz"

Giải nén và di chuyển thư mục

::

  tar -xzvf jdk-7u45-linux-x64.tar.gz
  sudo mv jdk1.7.0_45 /usr/lib/jvm/jdk1.7.0_45

Cài đặt java:

::

  sudo update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.7.0_45/bin/java" 1
  sudo update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/jdk1.7.0_45/bin/javac" 1
  sudo update-alternatives --install "/usr/bin/javap" "javap" "/usr/lib/jvm/jdk1.7.0_45/bin/javap" 1
  sudo update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/lib/jvm/jdk1.7.0_45/bin/javaws" 1

Chọn đường dẫn đến phiên bản Java

::

  sudo update-alternatives --config java

Ví dụ output:

::

  There are 3 choices for the alternative java (providing /usr/bin/java).

    Selection    Path                               Priority   Status
  ------------------------------------------------------------
  * 0            /usr/lib/jvm/jdk1.7.0_25/bin/java   50001     auto mode
    1            /usr/lib/jvm/jdk1.7.0_15/bin/java   50000     manual mode
    2            /usr/lib/jvm/jdk1.7.0_25/bin/java   50001     manual mode
    3            /usr/lib/jvm/jdk1.7.0_45/bin/java   1         manual mode

  Press enter to keep the current choice[*], or type selection number: 3
  update-alternatives: using /usr/lib/jvm/jdk1.7.0_45/bin/java to provide /usr/bin/java (java) in manual mode

Kiểm tra phiên bản Java:

::

  java -version

Ví dụ output:

::

  java version "1.7.0_45"
  Java(TM) SE Runtime Environment (build 1.7.0_45-b18)
  Java HotSpot(TM) 64-Bit Server VM (build 24.45-b08, mixed mode)

Tương tự với javac, javap, javaws:

::

  sudo update-alternatives --config javac
  sudo update-alternatives --config javap
  sudo update-alternatives --config javaws

Chạy Xitrum ở chế độ sản phẩm khi hệ thống khởi động
--------------------------------------------------------

``script/runner`` (cho các hệ thông Unix-like) và ``script/runner.bat`` (cho Windows) là các đoạn script
để chạy bất cứ đối tượng nào có method ``main``. Sử dụng chúng để khởi động web server trong môi trường
sản phẩm.

::

  script/runner quickstart.Boot

Bạn có thể sửa ``runner`` (hoặc ``runner.bat``) để chỉnh
`JVM settings <http://www.oracle.com/technetwork/java/hotspotfaq-138619.html>`_.
Xem thêm ``config/xitrum.conf``.

Để khởi động Xitrum ẩn trên Linux khi khởi động hệ thống, cách đơn giản là thêm dòng
sau vào ``/etc/rc.local``:

::

  su - user_foo_bar -c /path/to/the/runner/script/above &

`daemontools <http://cr.yp.to/daemontools.html>`_ là một giải pháp khác, để cài đặt trên Centos
xem `hướng dẫn <http://whomwah.com/2008/11/04/installing-daemontools-on-centos5-x86_64/>`_.

Hoặc sử dụng `Supervisord <http://supervisord.org/>`_.
Ví dụ ``/etc/supervisord.conf``:

::

  [program:my_app]
  directory=/path/to/my_app
  command=/path/to/my_app/script/runner quickstart.Boot
  autostart=true
  autorestart=true
  startsecs=3
  user=my_user
  redirect_stderr=true
  stdout_logfile=/path/to/my_app/log/stdout.log
  stdout_logfile_maxbytes=10MB
  stdout_logfile_backups=7
  stdout_capture_maxbytes=1MB
  stdout_events_enabled=false
  environment=PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/aws/bin:~/bin

Các giải pháp khác:

* `runit <http://smarden.org/runit/>`_
* `upstart <http://upstart.ubuntu.com/>`_

Thiết lập cổng chuyển tiếp
----------------------

Xitrum mặc định giao tiếp trên cổng 8000 và 4430.
Bạn có thể đổi cổng trong ``config/xitrum.conf``.

Bạn có thể thay đổi ``/etc/sysconfig/iptables`` với các lệnh sau để chuyển tiếp cổng
80 sang 8000 và 443 sang 4430:

::

  sudo su - root
  chmod 700 /etc/sysconfig/iptables
  iptables-restore < /etc/sysconfig/iptables
  iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8000
  iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 443 -j REDIRECT --to-port 4430
  iptables -t nat -I OUTPUT -p tcp -d 127.0.0.1 --dport 80 -j REDIRECT --to-ports 8000
  iptables -t nat -I OUTPUT -p tcp -d 127.0.0.1 --dport 443 -j REDIRECT --to-ports 4430
  iptables-save -c > /etc/sysconfig/iptables
  chmod 644 /etc/sysconfig/iptables

Tất nhiên nếu Apache sử dụng cổng 80 và 443, bạn sẽ cần phải dùng Apache:

::

  sudo /etc/init.d/httpd stop
  sudo chkconfig httpd off

Tham khao:

* `Iptables tutorial <http://www.frozentux.net/iptables-tutorial/chunkyhtml/>`_

Cấu hình Linux để kết nối hàng loạt
----------------------------------

Nhớ rằng trên MacOS,
`JDK có vấn đề nghiêm trọng với tốc độ IO (NIO) <https://groups.google.com/forum/#!topic/spray-user/S-SNR2m0BWU>`_.

Tham khảo:

* `Linux Performance Tuning (Riak) <http://docs.basho.com/riak/latest/ops/tuning/linux/>`_
* `AWS Performance Tuning (Riak) <http://docs.basho.com/riak/latest/ops/tuning/aws/>`_
* `Ipsysctl tutorial <http://www.frozentux.net/ipsysctl-tutorial/chunkyhtml/>`_
* `TCP variables <http://www.frozentux.net/ipsysctl-tutorial/chunkyhtml/tcpvariables.html>`_

Tăng số lượng các tệp được mở
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Mỗi connection với Linux là một tệp được mở.
Mặc định số lượng tối đa các tệp được mở là 1024.
Để tăng giới hạn, sửa tệp ``/etc/security/limits.conf``:

::

  *  soft  nofile  1024000
  *  hard  nofile  1024000

Bạn cần đăng xuất và đăng nhập lại hệ thống để kết thúc việc sửa đổi.
Để xác nhận chạy ``ulimit -n``.

Điều chỉnh kernel
~~~~~~~~~~~~~~~~~


Như được dẫn trong
`A Million-user Comet Application with Mochiweb <http://www.metabrew.com/article/a-million-user-comet-application-with-mochiweb-part-1>`_,
sửa tệp /etc/sysctl.conf:

::

  # General gigabit tuning
  net.core.rmem_max = 16777216
  net.core.wmem_max = 16777216
  net.ipv4.tcp_rmem = 4096 87380 16777216
  net.ipv4.tcp_wmem = 4096 65536 16777216

  # This gives the kernel more memory for TCP
  # which you need with many (100k+) open socket connections
  net.ipv4.tcp_mem = 50576 64768 98152

  # Backlog
  net.core.netdev_max_backlog = 2048
  net.core.somaxconn = 1024
  net.ipv4.tcp_max_syn_backlog = 2048
  net.ipv4.tcp_syncookies = 1

  # If you run clients
  net.ipv4.ip_local_port_range = 1024 65535
  net.ipv4.tcp_tw_recycle = 1
  net.ipv4.tcp_tw_reuse = 1
  net.ipv4.tcp_fin_timeout = 10

Chạy ``sudo sysctl -p`` để áp dụng các thay đổi.
Không cần khởi động lại hệ thống, kernel đã có khả năng xử lý nhiều kết nối hơn.

Lưu ý về backlog
~~~~~~~~~~~~~~~~

TCP thực hiện bắt tay 3 bước để thiết lập kết nối.
Khi một client từ xa kết nối đến máy chủ, client sẽ gửi một gói tin SYN.
Và hệ điều hành của phía máy chủ sẽ gửi lại các gói tin SYN-ACK.
Sau đó, khách hàng từ xa thiết lập một kết nối bằng cách gửi một gói tin ACK lại.
Xitrum sẽ nhận được nó khi kết nối được thiết lập đầy đủ.

Theo như
`Socket backlog tuning for Apache <https://sites.google.com/site/beingroot/articles/apache/socket-backlog-tuning-for-apache>`_,
connection timeout xảy ra khi gói tin SYN bị mất bởi backlog queue của web server bị
lấp đầy bởi các kết nối gửi SYN-ACK đến các client chậm.

Theo như
`FreeBSD Handbook <http://www.freebsd.org/doc/en_US.ISO8859-1/books/handbook/configtuning-kernel-limits.html>`_,
giá trị mặc định của là 128 thường quá thấp để xử lý các kết nối mới trong một server
có tải lớn. Đối với các máy chủ như vậy, nên tăng giá trị này thành 1024 hoặc hơn.
Listen queue lớn hơn cũng là cách tốt để chống lại việc tấn công từ chối dịch vụ (Denial of Service - DoS)

Backlog size của Xitrum được đặt thành 1024 (memcached cũng dùng giá trị này),
nhưng bạn cũng cần chỉnh kernel như trên.
The backlog size of Xitrum is set to 1024 (memcached also uses this value),

Kiểm tra cấu hình backlog:

::

  cat /proc/sys/net/core/somaxconn

hoặc:

::

  sysctl net.core.somaxconn

Để điều chỉnh tạm thời, bạn có thể làm như sau:

::

  sudo sysctl -w net.core.somaxconn=1024

HAProxy tip
-----------

Để cấu hình HAProxy cho SockJS, xem `ví dụ <https://github.com/sockjs/sockjs-node/blob/master/examples/haproxy.cfg>`_:

::

  defaults
      mode http
      timeout connect 10s
      timeout client  10h  # Set to long time to avoid WebSocket connections being closed when there's no network activity
      timeout server  10h  # Set to long time to avoid ERR_INCOMPLETE_CHUNKED_ENCODING on Chrome

  frontend xitrum_with_discourse
      bind 0.0.0.0:80

      option forwardfor

      acl is_discourse path_beg /forum
      use_backend discourse if is_discourse
      default_backend xitrum

  backend xitrum
      server srv_xitrum 127.0.0.1:8000

  backend discourse
      server srv_discourse 127.0.0.1:3000

Để HAProxy tải lại tệp cấu hình mà không cần khởi động lại, xem `cuộc thảo luận <http://serverfault.com/questions/165883/is-there-a-way-to-add-more-backend-server-to-haproxy-without-restarting-haproxy>`_.

HAProxy thì dễ sử dụng hơn Nginx. Nó phù hợp với Xitrum bởi như được đề cập đến trong
:doc:`the section about caching </cache>`, Các tệp tĩnh trong Xitrum thì
`very fast <https://gist.github.com/3293596>`_. Bạn không cần sử dụng các tệp tĩnh
để phục vụ các tĩnh năng của Nginx.

Nginx tip
---------

Nếu bạn sửu dụng tính năng WebSocket hoặc SockJS trong Xitrum và muốn chạy Xitrum ẩn sau
Nginx 1.2, bạn phải cài đặt thêm module như
`nginx_tcp_proxy_module <https://github.com/yaoweibin/nginx_tcp_proxy_module>`_.
Nginx 1.3+ hỗ trợ WebSocket.

Mặc định Nginx sử dụng giao thức HTTP 1.0 để reverse proxy. Nếu backend server trả về
chunked response, bạn cần báo Nginx sử dụng HTTP 1.1 như sau:

::

  location / {
    proxy_http_version 1.1;
    proxy_set_header Connection "";
    proxy_pass http://127.0.0.1:8000;
  }

`Tài liệu này <http://nginx.org/en/docs/http/ngx_http_upstream_module.html#keepalive>`_ chỉ ra rằng để http keepalive, bạn cũng
nên đặt proxy_set_header Connection "";

Triển khai trên Heroku
----------------------

Bạn cũng có thẻ chạy Xitrum trên `Heroku <https://www.heroku.com/>`_.

Đăng ký và tạo repository
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Làm theo `Official Document <https://devcenter.heroku.com/articles/quickstart>`_,
để đăng ký và tạo repository.

Tạo Procfile
~~~~~~~~~~~~~~~

Tạo Procfile và lưu tại thư mục gốc của project. Heroku đọc tệp này thực thi khi khởi động.

::

  web: target/xitrum/script/runner <YOUR_PACKAGE.YOUR_MAIN_CLASS>

Thay đổi thiết lập cổng
~~~~~~~~~~~~~~~~~~~~~~~

Vì Heroku sử dụng cổng một cách tự động, bạn cần làm như sau:

config/xitrum.conf:

::

  port {
    http              = ${PORT}
    # https             = 4430
    # flashSocketPolicy = 8430  # flash_socket_policy.xml will be returned
  }

Nếu bạn muốn sử dụng SSL, bạn cần `add on <https://addons.heroku.com/ssl>`_.

Xem log level
~~~~~~~~~~~~~

config/logback.xml:

::

  <root level="INFO">
    <appender-ref ref="CONSOLE"/>
  </root>

Tail log từ Heroku command:

::

  heroku logs -tail

Tạo alias cho ``xitrum-package``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tại thời điểm triển khai, Heroku chạy ``sbt/sbt clean compile stage``. Vì vậy bạn cần thêm
alias cho ``xitrum-package``.

build.sbt:

::

  addCommandAlias("stage", ";xitrum-package")


Push lên Heroku
~~~~~~~~~~~~~~~

Quá trình triển khai được nối bởi git push.

::

  git push heroku master


Xem thêm `Official document cho Scala <https://devcenter.heroku.com/articles/getting-started-with-scala>`_.
