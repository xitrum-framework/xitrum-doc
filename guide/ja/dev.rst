開発環境の構築(SBT, Eclipse/IntelliJ IDEA, and JRebel)
======================================================

Eclipseプロジェクトの作成
-------------------------

開発環境に `Eclipse <http://scala-ide.org/>`_ を使用する場合

プロジェクトディレクトリで以下のコマンドを実行します:

::

  sbt/sbt eclipse

``build.sbt`` に記載されたプロジェクト設定に応じてEclipse用の ``.project`` ファイルが生成されます。
Eclipseを起動してインポートしてください。

IntelliJ IDEAプロジェクトの作成
-------------------------------

開発環境に `IntelliJ IDEA <http://www.jetbrains.com/idea/>`_ を仕様する場合

プロジェクトディレクトリで以下のコマンドを実行します:

::

  sbt/sbt gen-idea

``build.sbt`` に記載されたプロジェクト設定に応じてIntelliJ用の ``.idea`` ファイルが生成されます。
IntelliJを起動してインポートしてください。


ignoreファイルの設定
--------------------

:doc:`チュートリアル </tutorial>` に沿ってプロジェクトを作成した場合 `ignored <https://github.com/xitrum-framework/xitrum-new/blob/master/.gitignore>`_ を参考にignoreファイルを作成してください。

::

  .*
  log
  project/project
  project/target
  routes.cache
  target

JRebelのインストール
--------------------

開発時には ``sbt/sbt run`` でサーバーを起動することができます。
通常、ソースコードを変更した場合、CTRL+Cでサーバーを停止し、再度 ``sbt/sbt run`` を実行する必要があります。
これには毎回10秒ほどかかってしまいます。

`JRebel <http://www.zeroturnaround.com/jrebel/>`_ を使用することでこの問題を回避することができます。
JRabelはScala開発者に無料ライセンスを提供しています。

インストール:

1. `free license for Scala <http://sales.zeroturnaround.com/>`_ を入手します。
2. 上記のライセンスを使用してJRebelをダウンロードしインストールします。
3. ``sbt/sbt`` に ``-noverify -javaagent:/path/to/jrebel/jrebel.jar`` を追記します。

例:

::

  java -noverify -javaagent:"$HOME/opt/jrebel/jrebel.jar" \
       -Xmx1024m -XX:MaxPermSize=128m -Dsbt.boot.directory="$HOME/.sbt/boot" \
       -jar `dirname $0`/sbt-launch.jar "$@"

JRebelの使用方法
----------------

1. ``sbt/sbt run`` を実行します。
2. Eclipse上で任意のScalaファイルを編集し保存します。

EclipseのScalaプラグインが自動的にリコンパイルし、生成されたクラスファイルをJRebelがリロードしてくれます。

Eclipse以外のテキストエディターを使用する場合

1. ``sbt/sbt run`` を実行します。
2. 別のターミナル画面で ``sbt/sbt ~compile`` を実行し継続的コンパイルモードでコンソールを起動します。
3. エディター上でScalaファイルを編集し保存します。

``sbt/sbt ~compile`` で起動したプロセスが自動的にリコンパイルを実施し、生成されたクラスファイルをJRebelがリロードしてくれます。

bash、shを使用している場合 ``sbt/sbt ~compile`` は問題なく実行できます。
zshを使用している場合, ``sbt/sbt "~compile"`` とすることで"no such user or named directory: compile"のエラーを回避できます。

なお、現時点ではJRebelを使用していてもルーティングはリロードされません。

JRebelをEclipse内で使用する場合 `こちらのチュートリアル <http://zeroturnaround.com/software/jrebel/eclipse-jrebel-tutorial/>`_ を参照してください。
