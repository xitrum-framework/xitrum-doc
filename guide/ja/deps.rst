依存ライブラリ
==============

Xitrumは以下のライブラリにが依存しています。
つまりあなたのXitrumプロジェクトはこれらのライブラリを直接使用することができます。

.. image:: ../img/deps.png

* `Scala <http://www.scala-lang.org/>`_:
  XitrumはScalaで書かれています。
* `Netty <https://netty.io/>`_:
  WebSocketやゼロコピーファイルサービングなど
  Xitrumの非同期HTTP(S)サーバの多くの機能はNettyの機能を元に実現しています。
* `Akka <http://akka.io/>`_:
  主にSockJSのために。Akkaは `Typesafe Config <https://github.com/typesafehub/config>`_
  に依存しており、Xitrumもまたそれを使用しています。
* `Rhino <https://developer.mozilla.org/en-US/docs/Rhino>`_:
  Scalate内でCoffeeScriptをJavaScriptにコンパイルするために使用します。
* `JSON4S <https://github.com/json4s/json4s>`_:
  JSONのパースと生成のために使用します。
  JSON4Sは `Paranamer <http://paranamer.codehaus.org/>`_ を使用しています。
* `Sclasner <https://github.com/xitrum-framework/sclasner>`_:
  クラスファイルとjarファイルからHTTPルートをスキャンするために使用しています。
* `Scaposer <https://github.com/xitrum-framework/scaposer>`_:
  国際化対応のために使用しています。
* `Commons Lang <http://commons.apache.org/lang/>`_:
  JSONデータのエスケープに使用しています。
* `Twitter Chill <https://github.com/twitter/chill>`_:
  クッキーとセッションのシリアライズ・デシリアライズに使用しています。
  Chillは `Kryo <http://code.google.com/p/kryo/>`_ を元にしています。
* `SLF4J <http://www.slf4j.org/>`_ と `Logback <http://logback.qos.ch/>`_:
  ロギングのために使用しています。
* `Schwatcher <https://github.com/lloydmeta/schwatcher/>`_:
  ファイルモニターのために使用しています。
* `Metrics-Scala <https://github.com/erikvanoosten/metrics-scala/>`_:
  メトリクス取得のために使用しています。Metrics-Scalaは `Metrics <http://metrics.codahale.com/>`_ を元にしています。


Xitrumはデフォルトで `xitrum-scalate <https://github.com/xitrum-framework/xitrum-scalate>`_ をテンプレートエンジンとして使用しており、
それは `Scalate <http://scalate.fusesource.org/>`_ と `Scalamd <https://github.com/chirino/scalamd>`_ を使用しています。
