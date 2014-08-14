ログ
====

xitrum.Logオブジェクトを直接使用する
-------------------------------------

xitrum.Logはどこからでも直接使用することができます:

::

  xitrum.Log.debug("My debug msg")
  xitrum.Log.info("My info msg")
  ...

xitrum.Logトレイトを直接使用する
--------------------------------

ログが生成された場所(クラス)を明確に知りたい場合、
xitrum.Logトレイトを継承します。

::

  package my_package
  import xitrum.Log

  object MyModel extends Log {
    log.debug("My debug msg")
    log.info("My info msg")
    ...
  }

``log/xitrum.log`` にはメッセージが ``MyModel`` から出力されていることがわかります。

Xitrumのアクションはxitrum.Logトレイトを継承しており、どのactionからでも以下のようにログを出力することができます:

::

  log.debug("Hello World")

ログレベルをチェックする必要はありません
----------------------------------------

``xitrum.Log`` は `SLF4S <http://slf4s.org/>`_ (`API <http://slf4s.org/api/1.7.7/>`_) を使用しており、
SLF4Sは `SLF4J <http://www.slf4j.org/>`_ の上に構築されています。

ログに出力時の計算によるCPU負荷を減らす目的で、ログ出力前にログレベルをチェックする伝統的な手法がありますが、
`SLF4Sが自動でチェックしてくれる <https://github.com/mattroberts297/slf4s/blob/master/src/main/scala/org/slf4s/Logger.scala>`_ ため、
あなたが気にする必要はありません。


これまで (このコードは Xitrum 3.13 以降では動作しません):

::

  if (log.isTraceEnabled) {
    val result = heavyCalculation()
    log.trace("Output: {}", result)
  }

現行:

::

  log.trace(s"Output: #{heavyCalculation()}")

ログレベル、ログファイル等の設定
--------------------------------

build.sbtに以下の1行があります:

::

  libraryDependencies += "ch.qos.logback" % "logback-classic" % "1.1.2"

これはデフォルトで `Logback <http://logback.qos.ch/>`_ が使用されていることを意味します。
Logbackの設定ファイルは ``config/logback.xml`` になります。

Logback以外の `SLF4J <http://www.slf4j.org/>`_ 対応ライブラリに置き換えることも可能です。