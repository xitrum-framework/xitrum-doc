Шаблонизация
============

Выбранный шаблонизатор используется во время вызова методов :doc:`renderView, renderFragment,
или respondView </action_view>`.

Настройка
---------

В конфигурационном файле `config/xitrum.conf <https://github.com/xitrum-framework/xitrum-new/blob/master/config/xitrum.conf>`_, шаблонизатор может быть указан двумя способами:

::

  template = my.template.EngineClassName

Или:

::

  template {
    "my.template.EngineClassName" {
      option1 = value1
      option2 = value2
    }
  }

По умолчанию используется `xitrum-scalate <https://github.com/xitrum-framework/xitrum-scalate>`_ в качестве шаблонизатора.

Отключение шаблонизатора
------------------------

В случае если ваш проект предоставляет просто API, обычно шаблонизатор не требуется. В этом случае
допускается убрать шаблонизатор из проекта что бы сделать его легче. Просто удалите 
``templateEngine`` в config/xitrum.conf. 

Реализация своего шаблонизатора
-------------------------------

Для реализации своего шаблонизатора, создайте класс реализующий `xitrum.view.TemplateEngine <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/view/TemplateEngine.scala>`_.
После этого укажите имя этого класса в конфигурации config/xitrum.conf.

Пример реализации `xitrum-scalate <https://github.com/xitrum-framework/xitrum-scalate>`_.
