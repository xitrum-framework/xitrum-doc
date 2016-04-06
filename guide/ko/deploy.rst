프로덕션 서버에 배포하기
==================

Xitrum을 직접 배포할수 있습니다:

::

  브라우저 ------ Xitrum 인스턴스

HAProxy와 같은 로드밸런서 뒤 혹은、Apache 의 Nginx와 같은 리버스 프록시에:

::

  브라우저 ------ 로드밸런서/리버스 프록시   -+---- Xitrum 인스턴스1
                                     +---- Xitrum 인스턴스2

Package 디렉토리
--------------------------

``sbt/sbt xitrum-package`` 를 실행하여 배포될 ``target/xitrum`` 디렉토리를 준비합니다:

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

사용자 정의 xitrum-package
-----------------------

기본적으로 ``sbt/sbt xitrum-package`` 명령은 수정된 ``config`` 、 ``public`` 그리고 ``script`` 를 ``target/xitrum`` 복사합니다
복사할 파일이나 디렉토리를 추가하려면 ``build.sbt`` 파일을 수정하면 됩니다:

::

  XitrumPackage.copy("config", "public, "script", "doc/README.txt", "etc.")

자세한 내용은 `xitrum-package 사이트 <https://github.com/xitrum-framework/xitrum-package>`_ 를 참조하세요.

실행중인 JVM 프로세스에 Scala 콘솔 연결
--------------------------------

프로덕션 환경에서도 특별한 준비없이 `Scalive <https://github.com/xitrum-framework/scalive>`_를 사용하여
실행중인 JVM 프로세스에 대해 Scala 콘솔을 연결하고 디버깅을 할 수 있습니다.

``script`` 디렉토리에서 ``scalive`` 실행하면 됩니다:

::

  script
    runner
    runner.bat
    scalive
    scalive.jar
    scalive.bat

Oracle JDK를 CentOS 나 우분투에 설차하기
----------------------------------

여기에서는 Java를 설치하는 방법에 대한 간단한 가이드를 소개합니다.
패키지 관리자를 사용하여 Java를 설치할 수 있습니다.

현재 설치되어 있는 Java 확인:

::

  sudo update-alternatives --list java

출력예제:

::

  /usr/lib/jvm/jdk1.7.0_15/bin/java
  /usr/lib/jvm/jdk1.7.0_25/bin/java

머신환경 확인 (32 bit 또는 64 bit):

::

  file /sbin/init

출력예:

::

  /sbin/init: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.24, BuildID[sha1]=0x4efe732752ed9f8cc491de1c8a271eb7f4144a5c, stripped

JDK를 `Oracle <http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html>`_ 사이트에서 다운로드합니다.
브라우저를 통하지 않고 다운로드하려면 약간의 `트릭 <http://stackoverflow.com/questions/10268583/how-to-automate-download-and-instalation-of-java-jdk-on-linux>`_이 필요합니다 :

::

  wget --no-cookies --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com" "http://download.oracle.com/otn-pub/java/jdk/7u45-b18/jdk-7u45-linux-x64.tar.gz"

압축을 해제하고 이동합니다:

::

  tar -xzvf jdk-7u45-linux-x64.tar.gz
  sudo mv jdk1.7.0_45 /usr/lib/jvm/jdk1.7.0_45

명령을 등록합니다:

::

  sudo update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.7.0_45/bin/java" 1
  sudo update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/jdk1.7.0_45/bin/javac" 1
  sudo update-alternatives --install "/usr/bin/javap" "javap" "/usr/lib/jvm/jdk1.7.0_45/bin/javap" 1
  sudo update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/lib/jvm/jdk1.7.0_45/bin/javaws" 1

인터랙티브 쉘에서 새 경로를 지정합니다:

::

  sudo update-alternatives --config java

출력예제:

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

버전 체크:

::

  java -version

출력예제:

::

  java version "1.7.0_45"
  Java(TM) SE Runtime Environment (build 1.7.0_45-b18)
  Java HotSpot(TM) 64-Bit Server VM (build 24.45-b08, mixed mode)

javac 등도 마찬가지로 합니다:

::

  sudo update-alternatives --config javac
  sudo update-alternatives --config javap
  sudo update-alternatives --config javaws

시스템이 구동될때 Xitrum을 시작하기
--------------------------------------

``script / runner`` (*nix 환경)과 ``script / runner.bat`` (Windows 환경)은 객체의``main`` 메소드를 실행하기위한 스크립트입니다. 프로덕션 환경에서는이 스크립트를 사용하여 Web 서버를 시작합니다 :

::

  script/runner quickstart.Boot

`JVM 설정 <http://www.oracle.com/technetwork/java/hotspotfaq-138619.html>`_을 수정하려면
``runner`` (또는``runner.bat``)을 수정합니다.
또한``config / xitrum.conf`` 참조하십시오.

리눅스에서 시스템이 시작할때 백그라운드로 Xitrum이 구동되길 원한다면, 간단하게 ``/etc/rc.local`` 에 라인을 추가해도
됩니다:

::

  su - user_foo_bar -c /path/to/the/runner/script/above &

`daemontools <http://cr.yp.to/daemontools.html>`_ 는 또다른 방법입니다.
CentOS에 설치하는 방법은 `설치방법 <http://whomwah.com/2008/11/04/installing-daemontools-on-centos5-x86_64/>`_ 을 참고하세요
또는 `Supervisord <http://supervisord.org/>`_ 도 있습니다

``/etc/supervisord.conf`` 예제:

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

다른 방법:

* `runit <http://smarden.org/runit/>`_
* `upstart <http://upstart.ubuntu.com/>`_

포트포워딩 방법
-----------

기본적으로 Xitrum는 8000 포트와 4430 포트를 사용합니다.
이 포트 번호는``config / xitrum.conf``으로 설정할 수 있습니다.

``/ etc / sysconfig / iptables``를 다음 명령으로 수정함으로써
80에서 8000에 443에서 4430로 포트 포워딩을 수행 할 수 있습니다 :

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

만약 Apache가 80포트、443포트를 사용하고 있다면, 반드시 멈추고 실행해야 합니다:

::

  sudo /etc/init.d/httpd stop
  sudo chkconfig httpd off

Iptables에 대한 좋은 정보:

* `Iptables 튜토리얼 <http://www.frozentux.net/iptables-tutorial/chunkyhtml/>`_

대량연결에 대한 Linux 설정
---------------------------------

Mac의 경우 JDK는`IO (NIO)에 관련된 성능 문제 <https://groups.google.com/forum/#!topic/spray-user/S-SNR2m0BWU>`_가 존재합니다.

참고자료:

* `Linux Performance Tuning (Riak) <http://docs.basho.com/riak/latest/ops/tuning/linux/>`_
* `AWS Performance Tuning (Riak) <http://docs.basho.com/riak/latest/ops/tuning/aws/>`_
* `Ipsysctl tutorial <http://www.frozentux.net/ipsysctl-tutorial/chunkyhtml/>`_
* `TCP variables <http://www.frozentux.net/ipsysctl-tutorial/chunkyhtml/tcpvariables.html>`_


파일 디스크립터 제한
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

각 연결은 Linux에 오픈된 파일로 간주됩니다.
1 프로세스가 동시에 오픈 할 수있는 파일 디스크립터 수는 기본적으로 1024으로되어 있습니다.
이 제한을 변경하려면``/ etc / security / limits.conf``을 편집합니다 :

::

  *  soft  nofile  1024000
  *  hard  nofile  1024000

변경 내용을 적용하려면 로그 아웃 한 후 다시 로그인해야합니다.
일시적으로 적용하려면``ulimit -n`` 실행합니다.

커널 조정
~~~~~~~~~~~~~~~~~~~~~~

`A Million-user Comet Application with Mochiweb（영문） <http://www.metabrew.com/article/a-million-user-comet-application-with-mochiweb-part-1>`_ 에 소개된것 처럼、``/etc/sysctl.conf`` 를 편집합니다:

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

변경사항을 적용하기 위해、 ``sudo sysctl -p`` 를 실행합니다.
재부팅할 필요는 없습니다, 지금부터 더 많은 커넥션을 바로 수행이 가능합니다

백 로그에 대해
~~~~~~~~~~~~~~~~~~

TCP는 연결 확립을 위해 3 종류의 핸드 셰이크 방식을 사용합니다.
원격 클라이언트가 서버에 연결할 때 클라이언트는 SYN 패킷을 보냅니다.
그리고 서버 측의 OS는 SYN-ACK 패킷을 회신합니다.
그 후 원격 클라이언트는 다시 ACK 패킷을 전송하고 연결이 설정합니다.
Xitrum는 연결이 완전히 확립했을 때 가져옵니다.

`Socket backlog tuning for Apache (영어) <https://sites.google.com/site/beingroot/articles/apache/socket-backlog-tuning-for-apache>`_에 따르면,
연결 시간 제한은 Web 서버의 백 로그 큐가 SYN-ACK 패킷으로 흘러 버린 때 SYN 패킷이 손실되기 때문에 발생합니다.

`FreeBSD Handbook (영어) <http://www.freebsd.org/doc/en_US.ISO8859-1/books/handbook/configtuning-kernel-limits.html>`_에 따르면
기본 128이라는 설정은 고부하 서버 환경에 새로운 연결을 확실하게 받기에는 너무 낮은 수치입니다.
그런 환경에서는 1024 이상으로 설정하는 것이 좋다고 되어 있습니다.
큐 크기를 크게하는 것은 DoS 공격을 피하는 의미에서도 효과가 있습니다.

Xitrum는 백 로그 크기를 1024 (memcached와 같은 값)으로하고 있습니다.
그러나 위의 커널 튜닝을하는 것도 잊지 마십시오.


백 로그 설정 확인 방법 :

::

  cat /proc/sys/net/core/somaxconn

또는:

::

  sysctl net.core.somaxconn

一임시로 변경:

::

  sudo sysctl -w net.core.somaxconn=1024

HAProxy 팁
------------

HAProxy를 SockJS 위해 설정하려면 `샘플 <https://github.com/sockjs/sockjs-node/blob/master/examples/haproxy.cfg>`_을 참조하십시오.

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

HAProxy를 다시 시작하지 않고 설정 파일을로드하려면 `토론 <http://serverfault.com/questions/165883/is-there-a-way-to-add-more-backend-server- to-haproxy-without-restarting-haproxy>`_을 참조하십시오.

HAProxy는 Nginx보다 훨신 사용하기 쉽습니다.
:doc:` 캐시 </cache>` 에서 처럼、Xitrum은 `정적 파일전송이 매우 빠르므로 <https://gist.github.com/3293596>`_ 그렇기 때문에
정적 파일 전송에 Nginx를 준비 할 필요는 없습니다. 그 점에서 HAProxy는 Xitrum과 아주 궁합이 좋다고 말할 수 있습니다.

Nginx 팁
----------

Nginx 1.2 이전에 Xitrum를 사용하는 경우 Xitrum의 WebSocket과 SockJS 기능을 사용하려면
`nginx_tcp_proxy_module <https://github.com/yaoweibin/nginx_tcp_proxy_module>`_를 사용할 필요가 있습니다.
Nginx 1.3+ 이상은 기본적으로 WebSocket을 지원하고 있습니다.

Nginx는 기본적으로 HTTP 1.0을 역방향 프록시 프로토콜로 사용합니다.
청크 응답을 사용하는 경우, Nginx에 HTTP 1.1 프로토콜로 사용하는 것을 알려야합니다 :

::

  location / {
    proxy_http_version 1.1;
    proxy_set_header Connection "";
    proxy_pass http://127.0.0.1:8000;
  }


http keepalive에 대한 `문서 <http://nginx.org/en/docs/http/ngx_http_upstream_module.html#keepalive>`_ 에서 말하듯이 ``proxy_set_header Connection ""`` 로 설정해야 합니다

Heroku에 배포하기
------------------

Xitrum을 `Heroku <https://www.heroku.com/>`_ 에서 실행도 가능합니다

가입 및 리파지토리 만들기
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

`공식문서 <https://devcenter.heroku.com/articles/quickstart>`_ 에 따라 가입 및 저장소를 만듭니다

Procfile 생성
~~~~~~~~~~~~~~

Procfile를 만들고 프로젝트의 루트 디렉토리에 저장합니다.
Heroku는이 파일을 기초로 시작시 명령을 실행합니다.
포트 번호는``$ PORT``라는 변수에 Heroku에서 전달됩니다.

::

  web: target/xitrum/script/runner <YOUR_PACKAGE.YOUR_MAIN_CLASS> $PORT

Port설정 변경
~~~~~~~~~~~~~~

포트 번호는 Heroku에 의해 동적으로 할당되기 때문에 다음과 같이 할 필요가 있습니다:

config/xitrum.conf:

::

  port {
    http              = 8000
    # https             = 4430
    # flashSocketPolicy = 8430  # flash_socket_policy.xml will be returned
  }

SSL을 사용하기 원한다면、`add on <https://addons.heroku.com/ssl>`_ 을 참고하세요

로그 레벨 수정
~~~~~~~~~~~~~~~~

config/logback.xml:

::

  <root level="INFO">
    <appender-ref ref="CONSOLE"/>
  </root>

Heroku의 tail log 명령어:

::

  heroku logs -tail


``xitrum-package`` 별칭부여
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

배치 실행시 Heroku는``sbt / sbt clean compile stage``를 실행합니다.
따라서``xitrum-package`` 대한 별칭을 작성해야합니다.

build.sbt:

::

  addCommandAlias("stage", ";xitrum-package")


Heroku에 푸시하기
~~~~~~~~~~~~~~~~~~

배포 프로세스는 git push 에 의해 수행됩니다

::

  git push heroku master


Heroku `Scala 공식문서 <https://devcenter.heroku.com/articles/getting-started-with-scala>`_ 를 참고하세요.

