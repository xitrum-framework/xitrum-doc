Развертывание на сервере
========================

Вы можете запустить Xitrum напрямую:

::

  Браузер ------ экземпляр Xitrum сервера

Или добавить балансировщик нагрузки (например, HAProxy), или обратный прокси сервер (например, Apache или Nginx):

::

  Браузер ------ Балансировщик/Прокси -+---- экземпляр Xitrum сервера
                                       +---- экземпляр Xitrum сервера

Сборка
------

Используйте команду ``sbt/sbt xitrum-package`` для подготовки директории ``target/xitrum``, которая
может быть развернута на сервере:

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

Сборка и xitrum-package
-----------------------

По умолчанию команда ``sbt/sbt xitrum-package`` копирует директории
``config``, ``public``, и ``script`` в ``target/xitrum``. Если необходимо
дополнительно копировать какие-то директории или файлы измените ``build.sbt``
следующим образом:

::

  XitrumPackage.copy("config", "public, "script", "doc/README.txt", "etc.")

Подробнее смотри `xitrum-package <https://github.com/xitrum-framework/xitrum-package>`_.

Подключение Scala консоли к запущенному JVM процессу
----------------------------------------------------

В боевом режиме, при определенной настройке, допускается использовать
`Scalive <https://github.com/xitrum-framework/scalive>`_ для подключения
Scala консоли к работающему JVM процессу для живой отладки.

Запустите ``scalive`` из директории script:

::

  script
    runner
    runner.bat
    scalive
    scalive.jar
    scalive.bat

Установка Oracle JDK на CentOS или Ubuntu
-----------------------------------------

Приведенная информация размещена здесь для удобства. Вы можете установить Java используя
пакетный менеджер.

Проверьте установленные альтернативы:

::

  sudo update-alternatives --list java

Пример вывода:

::

  /usr/lib/jvm/jdk1.7.0_15/bin/java
  /usr/lib/jvm/jdk1.7.0_25/bin/java

Определите ваше окружение (32 бита или 64 бита):

::

  file /sbin/init

Пример вывода:

::

  /sbin/init: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.24, BuildID[sha1]=0x4efe732752ed9f8cc491de1c8a271eb7f4144a5c, stripped

Скачайте JDK по ссылке `Oracle <http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html>`_.
`Обходной путь <http://stackoverflow.com/questions/10268583/how-to-automate-download-and-instalation-of-java-jdk-on-linux>`_ для загрузки jdk без браузера:

::

  wget --no-cookies --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com" "http://download.oracle.com/otn-pub/java/jdk/7u45-b18/jdk-7u45-linux-x64.tar.gz"

Распакуйте и переместите в подходящею папку:

::

  tar -xzvf jdk-7u45-linux-x64.tar.gz
  sudo mv jdk1.7.0_45 /usr/lib/jvm/jdk1.7.0_45

Зарегистрируйте как альтернативу:

::

  sudo update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.7.0_45/bin/java" 1
  sudo update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/jdk1.7.0_45/bin/javac" 1
  sudo update-alternatives --install "/usr/bin/javap" "javap" "/usr/lib/jvm/jdk1.7.0_45/bin/javap" 1
  sudo update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/lib/jvm/jdk1.7.0_45/bin/javaws" 1

Установите как активную альтернативу:

::

  sudo update-alternatives --config java

Пример вывода:

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

Проверьте версию:

::

  java -version

Пример вывода:

::

  java version "1.7.0_45"
  Java(TM) SE Runtime Environment (build 1.7.0_45-b18)
  Java HotSpot(TM) 64-Bit Server VM (build 24.45-b08, mixed mode)

Установите альтернативы так же для:

::

  sudo update-alternatives --config javac
  sudo update-alternatives --config javap
  sudo update-alternatives --config javaws

Запускайте Xitrum в боевом режиме когда система запускается
-----------------------------------------------------------

Скрипт ``script/runner`` (для *nix) и ``script/runner.bat`` (для Windows) запускает
сервер в боевом окружении используя указанный объект как ``main`` класс.

::

  script/runner quickstart.Boot

Вы можете улучшить ``runner`` (или ``runner.bat``)
`настроив JVM <http://www.oracle.com/technetwork/java/hotspotfaq-138619.html>`_.
Так же смотри ``config/xitrum.conf``.

Для запуска Xitrum в фоновом режиме при старте Linux системы проще всего добавить строчку в ``/etc/rc.local``:

::

 su - user_foo_bar -c /path/to/the/runner/script/above &

Кроме того можно использовать утилиту `daemontools <http://cr.yp.to/daemontools.html>`_. Для установки на CentOS, смотри `инструкцию <http://whomwah.com/2008/11/04/installing-daemontools-on-centos5-x86_64/>`_.

Или используйте `Supervisord <http://supervisord.org/>`_.
Пример ``/etc/supervisord.conf``:

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

Настройка портов
----------------

Xitrum слушает порт 8000 и 4430 по умолчанию.
Вы можете изменить эти порты в конфигурации ``config/xitrum.conf``.

Вы можете обновить ``/etc/sysconfig/iptables`` для перенаправления портов
80 на 8000 и 443 на 4430:

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

Конечно в данном примере предполагается что эти порты свободны. Если на них работает Apache
остановите его командой:

::

  sudo /etc/init.d/httpd stop
  sudo chkconfig httpd off

Смотри так же:

* `Iptables <http://www.frozentux.net/iptables-tutorial/chunkyhtml/>`_

Настройка Linux для обработки большого числа подключений
--------------------------------------------------------

Важно: `JDK страдает серьезной проблемой производительности IO (NIO) на Mac <https://groups.google.com/forum/#!topic/spray-user/S-SNR2m0BWU>`_.

Смотри так же:

* `Linux Performance Tuning (Riak) <http://docs.basho.com/riak/latest/ops/tuning/linux/>`_
* `AWS Performance Tuning (Riak) <http://docs.basho.com/riak/latest/ops/tuning/aws/>`_
* `Ipsysctl tutorial <http://www.frozentux.net/ipsysctl-tutorial/chunkyhtml/>`_
* `TCP variables <http://www.frozentux.net/ipsysctl-tutorial/chunkyhtml/tcpvariables.html>`_

Увеличьте лимит открытых файлов
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Каждое подключение рассматривается операционной системой как открытый файл.
По умолчанию максимальное количество открытых файлов 1024.
Для увеличения этого лимита, исправьте /etc/security/limits.conf:

::

  *  soft  nofile  1024000
  *  hard  nofile  1024000

Нужно заново зайти в систему что бы этот конфигурация подействовала.
Убедитесь что лимит изменился ``ulimit -n``.

Оптимизация ядра
~~~~~~~~~~~~~~~~

Согласно
`A Million-user Comet Application with Mochiweb <http://www.metabrew.com/article/a-million-user-comet-application-with-mochiweb-part-1>`_,
измените /etc/sysctl.conf:

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

Выполните ``sudo sysctl -p`` что бы применить изменения. Перезагрузка не требуется,
теперь ваше ядро способно обработать гораздо больше подключений.

Замечание об использовании backlog
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TCP выполняет 3 рукопожатия (handshake) для установки соединения.
Когда удаленный клиент устанавливает подключение к серверу, он отправляет
SYN пакет, а сервер отвечает SYN-ACK, затем клиент посылает ACK пакет и
соединение устанавливается. Xitrum получает соединение после
того как оно было полностью установлено.

Согласно статье
`Socket backlog tuning for Apache <https://sites.google.com/site/beingroot/articles/apache/socket-backlog-tuning-for-apache>`_, таймаут подключение случается когда SYN пакет теряется. Это происходит потому что
очередь backlog переполняется подключениями посылающими SYN-ACK медленным клиентам.

Согласно
`FreeBSD Handbook <http://www.freebsd.org/doc/en_US.ISO8859-1/books/handbook/configtuning-kernel-limits.html>`_,
значение 128 обычно слишком мало для обработки подключений на высоко нагруженных серверах. Для
таких окружений, рекомендуется увеличить это значение до 1024 или даже выше. Это так же
способствует в предотвращении атак Denial of Service (DoS).

Размер backlog для Xitrum установлен в 1024 (memcached так же использует это значение),
но вам так же нужно изменить ядро как показано ниже.

Для проверки конфигурации backlog:

::

  cat /proc/sys/net/core/somaxconn

Или:

::

  sysctl net.core.somaxconn

Для установки нового значения используйте:

::

  sudo sysctl -w net.core.somaxconn=1024

HAProxy
-------

Смотри `пример <https://github.com/sockjs/sockjs-node/blob/master/examples/haproxy.cfg>`_ настройки HAProxy для SockJS.

В этом `обсуждении <http://serverfault.com/questions/165883/is-there-a-way-to-add-more-backend-server-to-haproxy-without-restarting-haproxy>`_ предлагается способ настройки HAProxy который позволяет перезагружать конфигурационные файлы без перезапуска сервера.

HAProxy гораздо проще в использовании чем Nginx. Он подходи Xitrum поскольку как сказано :doc:`в секции про кэширование </cache>`, Xitrum отдает статические файлы
`очень быстро <https://gist.github.com/3293596>`_. Вам не нужна возможность отдачи статики в Nginx.

Nginx
-----

Если вы используете WebSocket или SockJS в Xitrum и Nginx 1.2, то вам следует
установить дополнительный модуль `nginx_tcp_proxy_module <https://github.com/yaoweibin/nginx_tcp_proxy_module>`_.
Nginx 1.3+ поддерживает WebSocket из коробки.

Nginx по умолчанию использует протокол HTTP 1.0. Если ваш сервер возвращает
chunked response, вам нужно использовать протокол HTTP 1.1, пример:

::

  location / {
    proxy_http_version 1.1;
    proxy_set_header Connection "";
    proxy_pass http://127.0.0.1:8000;
  }

Как `сказано в документации <http://nginx.org/en/docs/http/ngx_http_upstream_module.html#keepalive>`_ к http keepalive, вам следует установить proxy_set_header Connection "";

Развертывание в Heroku
----------------------

Xitrum может быть запущен на `Heroku <https://www.heroku.com/>`_.

Зарегистрируйтесь и создайте репозиторий
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Следуя `официальной документации <https://devcenter.heroku.com/articles/quickstart>`_,
зарегистрируйтесь и создайте git репозиторий.

Создание Procfile
~~~~~~~~~~~~~~~~~

Создайте Procfile и сохраните его в корневой директории. Heroku читает этот файл
при старте. Номер порта передается Heroky в переменной ``$PORT``.

::

  web: target/xitrum/script/runner <YOUR_PACKAGE.YOUR_MAIN_CLASS> $PORT

Изменения порта
~~~~~~~~~~~~~~~

Поскольку Heroku назначает порт автоматически, используйте код:

config/xitrum.conf:

::

  port {
    http              = ${PORT}
    # https             = 4430
    # flashSocketPolicy = 8430  # flash_socket_policy.xml will be returned
  }

`Поддержка SSL <https://addons.heroku.com/ssl>`_.

Уровень логирования
~~~~~~~~~~~~~~~~~~~

config/logback.xml:

::

  <root level="INFO">
    <appender-ref ref="CONSOLE"/>
  </root>

Просмотр логов в Heroku:

::

  heroku logs -tail

Создание алиаса для ``xitrum-package``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Во время развертывания, Heroky выполняет ``sbt/sbt clean compile stage``.
Поэтому вам нужно добавить алиас для ``xitrum-package``.

build.sbt:

::

  addCommandAlias("stage", ";xitrum-package")


Развертывание на Heroku
~~~~~~~~~~~~~~~~~~~~~~~

Процесс развертывания запускается автоматически после git push.

::

  git push heroku master


Смотри также `официальная документация по языку Scala <https://devcenter.heroku.com/articles/getting-started-with-scala>`_.
