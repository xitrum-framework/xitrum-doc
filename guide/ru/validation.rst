Валидация
=========

Xitrum включает `плагин jQuery Validation <http://bassistance.de/jquery-plugins/jquery-plugin-validation/>`_
для выполнения валидации на стороне клиента и предоставляет наоборот утильных методов на серверной стороне.

Стандартные валидаторы
-----------------------

Xitrum предоставляет набор валидаторов из пакета ``xitrum.validator``.
Интерфейс валидатора:

::

  check(value): Boolean
  message(name, value): Option[String]
  exception(name, value)

В случае если проверка не проходит, ``message`` возвращает ``Some(error message)``,
а ``exception`` выбрасывает ``xitrum.exception.InvalidInput(error message)``.

Вы можете использовать валидаторы везде где захотите.

Пример контроллера:

::

  import xitrum.validator.Required

  @POST("articles")
  class CreateArticle {
    def execute() {
      val title = param("tite")
      val body  = param("body")
      Required.exception("Title", title)
      Required.exception("Body",  body)

      // дальнейшая обработка валидных title и body
    }
  }

Если вы не используете блок ``try`` и ``catch``, когда валидация не проходит,
Xitrum автоматически обработает исключение и отправит сообщение клиенту. Это удобно 
при написании API и когда у вас уже есть проверка на клиенте.

Пример модели:

::

  import xitrum.validator.Required

  case class Article(id: Int = 0, title: String = "", body: String = "") {
    def isValid           = Required.check(title)   &&     Required.check(body)
    def validationMessage = Required.message(title) orElse Required.message(body)
  }

Смотри `пакет xitrum.validator <https://github.com/xitrum-framework/xitrum/tree/master/src/main/scala/xitrum/validator>`_
для получения полного списка стандартных валидаторов.

Написание своих валидаторов
---------------------------

Наследуйтесь от `xitrum.validator.Validator <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/validator/Validator.scala>`_ для создания своего валидатора. Необходимо реализовать только методы ``check`` и ``message``.

Так же вы можете использовать библиотеку `Commons Validator <http://commons.apache.org/proper/commons-validator/>`_.
