Flashのソケットポリシーファイル
===============================

Flashのソケットポリシーファイルについて:

* http://www.adobe.com/devnet/flashplayer/articles/socket_policy_files.html
* http://www.lightsphere.com/dev/articles/flash_socket_policy.html

FlashのソケットポリシーファイルのプロトコルはHTTPと異なります。

XitrumからFlashのソケットポリシーファイルを返信するには:

1. `config/flash_socket_policy.xml <https://github.com/xitrum-framework/xitrum-new/blob/master/config/flash_socket_policy.xml>`_
   を修正します。
2. `config/xitrum.conf <https://github.com/xitrum-framework/xitrum-new/blob/master/config/xitrum.conf>`_
   を修正し上記ファイルの返信を有効にします。
