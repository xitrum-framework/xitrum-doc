プロダクション環境へのデプロイ
==============================

Xitrumを直接動かすことができます:

::

  ブラウザ ------ Xitrum インスタンス

HAProxyのようなロードバランサーや、ApacheやNginxのようなリバースプロキシの背後で動かすこともできます:

::

  ブラウザ ------ ロードバランサー/リバースプロキシ   -+---- Xitrum インスタンス1
                                              　+---- Xitrum インスタンス2

ディレクトリのパッケージ化
--------------------------

``sbt/sbt xitrum-package`` を実行することで、プロダクション環境へデプロイ可能な ``target/xitrum`` ディレクトリが生成されます:

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

xitrum-packageのカスタマイズ
----------------------------

デフォルトでは ``sbt/sbt xitrum-package`` コマンドは、

``config`` 、 ``public`` および ``script`` ディレクトリを ``target/xitrum`` 以下にコピーします。
コピーするディレクトリを追加したい場合は、以下のように ``build.sbt`` を編集します:

::

  XitrumPackage.copy("config", "public, "script", "doc/README.txt", "etc.")

詳しくは `xitrum-packageのサイト <https://github.com/xitrum-framework/xitrum-package>`_ を参照ください。

稼働中のJVMプロセスに対するScalaコンソール接続
----------------------------------------------

プロダクション環境においても特別な準備をすることなく、`Scalive <https://github.com/xitrum-framework/scalive>`_ を使用することで、
稼働中のJVMプロセスに対してScalaコンソールを接続してデバッギングを行うことができます。

``script`` ディレクトリの ``scalive`` コマンドを実行します:

::

  script
    runner
    runner.bat
    scalive
    scalive.jar
    scalive.bat

CentOSまたはUbuntuへのOracleJDKインストール
-------------------------------------------

ここではJavaのインストール方法についての簡単なガイドを紹介します。
パッケージマネージャを使用してJavaをインストールすることも可能です。

現在インストールされているJavaの確認:

::

  sudo update-alternatives --list java

出力例:

::

  /usr/lib/jvm/jdk1.7.0_15/bin/java
  /usr/lib/jvm/jdk1.7.0_25/bin/java

サーバ環境の確認 (32 bit または 64 bit):

::

  file /sbin/init

出力例:

::

  /sbin/init: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.24, BuildID[sha1]=0x4efe732752ed9f8cc491de1c8a271eb7f4144a5c, stripped

JDKを `Oracle <http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html>`_ のサイトからダウンロードします。
ブラウザを介さないでダウンロードするにはちょっとした `工夫 <http://stackoverflow.com/questions/10268583/how-to-automate-download-and-instalation-of-java-jdk-on-linux>`_ が必要です:

::

  wget --no-cookies --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com" "http://download.oracle.com/otn-pub/java/jdk/7u45-b18/jdk-7u45-linux-x64.tar.gz"

ダウンロードしたアーカイブを解凍して移動します:

::

  tar -xzvf jdk-7u45-linux-x64.tar.gz
  sudo mv jdk1.7.0_45 /usr/lib/jvm/jdk1.7.0_45

コマンドを登録します:

::

  sudo update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.7.0_45/bin/java" 1
  sudo update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/jdk1.7.0_45/bin/javac" 1
  sudo update-alternatives --install "/usr/bin/javap" "javap" "/usr/lib/jvm/jdk1.7.0_45/bin/javap" 1
  sudo update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/lib/jvm/jdk1.7.0_45/bin/javaws" 1

対話型のシェルで新しいパスを指定します:

::

  sudo update-alternatives --config java

出力例:

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

バージョンを確認します:

::

  java -version

出力例:

::

  java version "1.7.0_45"
  Java(TM) SE Runtime Environment (build 1.7.0_45-b18)
  Java HotSpot(TM) 64-Bit Server VM (build 24.45-b08, mixed mode)

javac等も同様に行います:

::

  sudo update-alternatives --config javac
  sudo update-alternatives --config javap
  sudo update-alternatives --config javaws

システム起動時にXitrumをスタートさせる
--------------------------------------

``script/runner`` （*nix環境向け）と ``script/runner.bat`` （Windows環境向け）はオブジェクトの ``main`` メソッドを実行するためのスクリプトになります。
プロダクション環境ではこのスクリプトを使用してWebサーバを起動します:

::

  script/runner quickstart.Boot

`JVM設定 <http://www.oracle.com/technetwork/java/hotspotfaq-138619.html>`_ を調整するには、
``runner`` （または ``runner.bat``）を修正します。
また、``config/xitrum.conf`` も参照してください。

Linux環境でシステム起動時にXitrumをバックグラウンドでスタートさせるには、一番簡単な方法は
``/etc/rc.local`` に一行を追加します:

::

  su - user_foo_bar -c /path/to/the/runner/script/above &

他には `daemontools <http://cr.yp.to/daemontools.html>`_ が便利です。
CentOSへのインストール手順は `こちらの手順 <http://whomwah.com/2008/11/04/installing-daemontools-on-centos5-x86_64/>`_ を参照してください。
あるいは `Supervisord <http://supervisord.org/>`_ を使用することもできます。

``/etc/supervisord.conf`` の例:

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

その他のツール:

* `runit <http://smarden.org/runit/>`_
* `upstart <http://upstart.ubuntu.com/>`_

ポートフォワーディングの設定
----------------------------

デフォルトではXitrumは8000ポートと4430ポートを使用します。
これらのポート番号は ``config/xitrum.conf`` で設定することができます。

``/etc/sysconfig/iptables`` を以下のコマンドで修正することによって、
80から8000へ、443から4430へポートフォワーディングを行うことができます:

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

もしApacheが80ポート、443ポートを使用している場合、停止する必要があります:

::

  sudo /etc/init.d/httpd stop
  sudo chkconfig httpd off

Iptablesについての参考情報:

* `Iptables チュートリアル <http://www.frozentux.net/iptables-tutorial/chunkyhtml/>`_

大量コネクションに対するLinux設定
---------------------------------

Macの場合、JDKは `IO (NIO) に関わるパフォーマンスの問題 <https://groups.google.com/forum/#!topic/spray-user/S-SNR2m0BWU>`_ が存在します。

参考情報(英語):

* `Linux Performance Tuning (Riak) <http://docs.basho.com/riak/latest/ops/tuning/linux/>`_
* `AWS Performance Tuning (Riak) <http://docs.basho.com/riak/latest/ops/tuning/aws/>`_
* `Ipsysctl tutorial <http://www.frozentux.net/ipsysctl-tutorial/chunkyhtml/>`_
* `TCP variables <http://www.frozentux.net/ipsysctl-tutorial/chunkyhtml/tcpvariables.html>`_


ファイルディスクリプタ数の上限設定
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

各コネクションはLinuxにとってオープンファイルとしてみなされます。
1プロセスが同時オープン可能なファイルディスクリプタ数は、デフォルトで1024となっています。
この上限を変更するには ``/etc/security/limits.conf`` を編集します:

::

  *  soft  nofile  1024000
  *  hard  nofile  1024000

変更を適用するには一度ログアウトして、再度ログインする必要があります。
一時的に適用するには ``ulimit -n`` と実行します。

カーネルのチューニング
~~~~~~~~~~~~~~~~~~~~~~

`A Million-user Comet Application with Mochiweb（英語） <http://www.metabrew.com/article/a-million-user-comet-application-with-mochiweb-part-1>`_ に紹介されているように、``/etc/sysctl.conf`` を編集します:

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

変更を適用するため、 ``sudo sysctl -p`` を実行します。
リブートの必要はありません。これでカーネルは大量のコネクションを扱うことができるようになります。

バックログについて
~~~~~~~~~~~~~~~~~~

TCPはコネクション確立のために3種類のハンドシェイクを行います。
リモートクライアントがサーバに接続するとき、クライアントはSYNパケットを送信します。
そしてサーバ側のOSはSYN-ACKパケットを返信します。
その後リモートクライアントは再びACKパケットを送信してコネクションが確立します。
Xitrumはコネクションが完全に確立した時にそれを取得します。

`Socket backlog tuning for Apache（英語） <https://sites.google.com/site/beingroot/articles/apache/socket-backlog-tuning-for-apache>`_ によると、
コネクションタイムアウトは、WebサーバのバックログキューがSYN−ACKパケット送信で溢れてしまった際に、SYNパケットが失われることによって発生します。

`FreeBSD Handbook（英語） <http://www.freebsd.org/doc/en_US.ISO8859-1/books/handbook/configtuning-kernel-limits.html>`_ によると
デフォルトの128という設定は、高負荷なサーバ環境にとって、新しいコネクションを確実に受け付けるには低すぎるとあります。
そのような環境では、1024以上に設定することが推奨されています。
キューサイズを大きくすることはDoS攻撃を避ける意味でも効果があります。

Xitrumはバックログサイズを1024(memcachedと同じ値)としています。
しかし、前述のカーネルのチューニングをすることも忘れないで下さい。


バックログ設定値の確認方法:

::

  cat /proc/sys/net/core/somaxconn

または:

::

  sysctl net.core.somaxconn

一時的な変更方法:

::

  sudo sysctl -w net.core.somaxconn=1024

HAProxy tips
------------

HAProxyをSockJSのために設定するには、`こちらのサンプル <https://github.com/sockjs/sockjs-node/blob/master/examples/haproxy.cfg>`_ を参照してください。
HAProxyを再起動せずに設定ファイルをロードするには、`こちらのディスカッション <http://serverfault.com/questions/165883/is-there-a-way-to-add-more-backend-server-to-haproxy-without-restarting-haproxy>`_ を参照してください。

HAProxyはNginxより簡単に使うことができます。
:doc:`キャッシュについての章 </cache>` にあるように、Xitrumは `静的ファイルの配信に優れている <https://gist.github.com/3293596>`_ ため、
静的ファイルの配信にNginxを用意する必要はありません。その点からHAProxyはXitrumととても相性が良いと言えます。

Nginx tips
----------

Nginx 1.2 の背後でXitrumを動かす場合、XitrumのWebSocketやSockJSの機能を使用するには、
`nginx_tcp_proxy_module <https://github.com/yaoweibin/nginx_tcp_proxy_module>`_ を使用する必要があります。
Nginx 1.3+ 以上はネイティブでWebSocketをサポートしています。

Nginxはデフォルトでは、HTTP 1.0をリバースプロキシのプロトコルとして使用します。
チャンクレスポンスを使用する場合、Nginxに HTTP 1.1をプロトコルとして使用することを伝える必要があります:

::

  location / {
    proxy_http_version 1.1;
    proxy_set_header Connection "";
    proxy_pass http://127.0.0.1:8000;
  }


http keepaliveについての `ドキュメント <http://nginx.org/en/docs/http/ngx_http_upstream_module.html#keepalive>`_ にあるように、 ``proxy_set_header Connection ""`` と設定する必要もあります。

Herokuへのデプロイ
------------------

Xitrumは `Heroku <https://www.heroku.com/>`_ 上で動かすこともできます。

サインアップとリポジトリの作成
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

`公式ドキュメント <https://devcenter.heroku.com/articles/quickstart>`_ に沿って、サインアップしリポジトリを作成します。

Procfileの作成
~~~~~~~~~~~~~~

Procfileを作成し、プロジェクトのルートディレクトリに保存します。
Herokuはこのファイルをもとに、起動時コマンドを実行します。
ポート番号は ``$PORT`` という変数でHerokuから渡されることになります。

::

  web: target/xitrum/script/runner <YOUR_PACKAGE.YOUR_MAIN_CLASS>

Port設定の変更
~~~~~~~~~~~~~~

ポート番号はHerokuによって動的にアサインされるため、以下のように設定する必要があります。

config/xitrum.conf:

::

  port {
    http              = ${PORT}
    # https             = 4430
    # flashSocketPolicy = 8430  # flash_socket_policy.xml will be returned
  }

SSLを使用するには、`アドオン <https://addons.heroku.com/ssl>`_ が必要となります。

ログレベルの設定
~~~~~~~~~~~~~~~~

config/logback.xml:

::

  <root level="INFO">
    <appender-ref ref="CONSOLE"/>
  </root>

Herokuで稼働するアプリのログをtailするには:

::

  heroku logs -tail


``xitrum-package`` のエイリアス作成
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

デプロイ実行時にHerokuは、``sbt/sbt clean compile stage`` を実行します。
そのため、 ``xitrum-package`` に対するエイリアスを作成する必要があります。

build.sbt:

::

  addCommandAlias("stage", ";xitrum-package")


Herokuへのプッシュ
~~~~~~~~~~~~~~~~~~

デプロイプロセスは git push にふっくされます:

::

  git push heroku master


詳しくはHerokuの `公式ドキュメント for Scala <https://devcenter.heroku.com/articles/getting-started-with-scala>`_ を参照してください.

OpenShiftへのデプロイ
---------------------

Xitrumは `OpenShift <https://developers.openshift.com/>`_ 上で動かすこともできます。

サインアップとリポジトリの作成
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

`公式ガイド <https://developers.openshift.com/en/getting-started-overview.html>`_ に沿って、サインアップしリポジトリを作成します。
カートリッジには `DIY <https://developers.openshift.com/en/diy-overview.html>`_ を指定します。

::

  rhc app create myapp diy



プロジェクト構成
~~~~~~~~~~~~~~~~

sbtを使用してXitrumアプリケーションをコンパイル、起動するために、`いくつかの準備 <http://stackoverflow.com/questions/23826770/play-openshift-deployment-sbt-using-some-directories-behind-the-scenes>`_ が必要となります。
rhcコマンドで作成したプロジェクトディレクトリ内に`app`ディレクトリを作成し、xitrumアプリケーションのソースコードを配置します。
また、空の`static`と`fakehome`ディレクトリを作成します、
プロジェクトツリーは以下のようになります。

::

  ├── .openshift
  │   ├── README.md
  │   ├── action_hooks
  │   │   ├── README.md
  │   │   ├── start
  │   │   └── stop
  │   ├── cron
  │   └── markers
  ├── README.md
  ├── app
  ├── fakehome
  ├── misc
  └── static


action_hooksの作成
~~~~~~~~~~~~~~~~~~

openshiftへpush時に実行されるスクリプトを以下のように修正します。

.openshift/action_hooks/start:

::

    #!/bin/bash
    IVY_DIR=$OPENSHIFT_DATA_DIR/.ivy2
    mkdir -p $IVY_DIR
    chown $OPENSHIFT_GEAR_UUID.$OPENSHIFT_GEAR_UUID -R "$IVY_DIR"
    cd $OPENSHIFT_REPO_DIR/app
    sbt/sbt xitrum-package
    nohup $OPENSHIFT_REPO_DIR/app/target/xitrum/script/runner quickstart.Boot >> nohup.out 2>&1 & echo $! > $OPENSHIFT_REPO_DIR/xitrum.pid &


.openshift/action_hooks/top:

::

  #!/bin/bash
  source $OPENSHIFT_CARTRIDGE_SDK_BASH

  # The logic to stop your application should be put in this script.
  if [ -z "$(ps -ef | grep `cat $OPENSHIFT_REPO_DIR/xitrum.pid` | grep -v grep)" ]
  then
      client_result "Application is already stopped"
  else
      cat $OPENSHIFT_REPO_DIR/xitrum.pid | xargs kill
  fi


IP:Port設定の変更
~~~~~~~~~~~~~~~~~

IPとポート番号はopenshiftによって動的にアサインされるため、以下のように設定する必要があります。

config/xitrum.conf:

::

  # Use opensift's Environment Variables
  interface = ${OPENSHIFT_DIY_IP}

  # Comment out the one you don't want to start.
  port {
    http  = ${OPENSHIFT_DIY_PORT}




sbt引数の修正
~~~~~~~~~~~~~

opensift上でsbtが動かすために、sbt起動スクリプトに以下のオプションを追加します。

sbt/sbt:

::

  -Duser.home=$OPENSHIFT_REPO_DIR/fakehome -Dsbt.ivy.home=$OPENSHIFT_DATA_DIR/.ivy2 -Divy.home=$OPENSHIFT_DATA_DIR/.ivy2


openshiftへのpush
~~~~~~~~~~~~~~~~~

アプリケーションを起動するにはopensiftへソースコードをプッシュします。

::

  git push
