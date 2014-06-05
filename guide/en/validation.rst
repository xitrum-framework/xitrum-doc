Validation
==========

Xitrum includes `jQuery Validation plugin <http://bassistance.de/jquery-plugins/jquery-plugin-validation/>`_
for validation at client side and provides validation helpers for server side.

Default validators
------------------

Xitrum provides validators in ``xitrum.validator`` package.
They have these methods:

::

  check(value): Boolean
  message(name, value): Option[String]
  exception(name, value)

If the validation check does not pass, ``message`` will return ``Some(error message)``,
``exception`` will throw ``xitrum.exception.InvalidInput(error message)``.

You can use validators anywhere you want.

Action example:

::

  import xitrum.validator.Required

  @POST("articles")
  class CreateArticle {
    def execute() {
      val title = param("tite")
      val body  = param("body")
      Required.exception("Title", title)
      Required.exception("Body",  body)

      // Do with the valid title and body...
    }
  }

If you don't ``try`` and ``catch``, when the validation check does not pass,
Xitrum will automatically catch the exception and respond the error message to
the requesting client. This is convenient when writing web APIs or when you
already have validation at the client side.

Model example:

::

  import xitrum.validator.Required

  case class Article(id: Int = 0, title: String = "", body: String = "") {
    def isValid           = Required.check(title)   &&     Required.check(body)
    def validationMessage = Required.message(title) orElse Required.message(body)
  }

See `xitrum.validator pakage <https://github.com/xitrum-framework/xitrum/tree/master/src/main/scala/xitrum/validator>`_
for the full list of default validators.

Write custom validators
-----------------------

Extend `xitrum.validator.Validator <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/validator/Validator.scala>`_.
You only have to implement ``check`` and ``message`` method.

You can also use `Commons Validator <http://commons.apache.org/proper/commons-validator/>`_.
