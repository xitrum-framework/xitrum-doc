XML
===

Scala позволяет использовать XML литералы. Xitrum позволяет использовать такую возможность как своеобразный "шаблонизатор":

* Scala проверяет синтаксис XML во время компиляции: представления безопасны относительно типа.
* Scala автоматически экранирует XML: представления по умолчанию защищены от `XSS <http://en.wikipedia.org/wiki/Cross-site_scripting>`_ атак.

Ниже приведены некоторые советы.

Отключения экранирования XML
--------------------------

Используйте ``scala.xml.Unparsed``:

::

  import scala.xml.Unparsed

  <script>
    {Unparsed("if (1 < 2) alert('Xitrum rocks');")}
  </script>

Или ``<xml:unparsed>``:

::

  <script>
    <xml:unparsed>
      if (1 < 2) alert('Xitrum rocks');
    </xml:unparsed>
  </script>

``<xml:unparsed>`` не отображается в выводе:

::

  <script>
    if (1 < 2) alert('Xitrum rocks');
  </script>

Группировка XML элементов
-------------------------

::

  <div id="header">
    {if (loggedIn)
      <xml:group>
        <b>{username}</b>
        <a href={url[LogoutAction]}>Logout</a>
      </xml:group>
    else
      <xml:group>
        <a href={url[LoginAction]}>Login</a>
        <a href={url[RegisterAction]}>Register</a>
      </xml:group>}
  </div>

``<xml:group>`` не будет отображаться в выводе, например в случае пользователя прошедшего аутентификацию:

::

  <div id="header">
    <b>My username</b>
    <a href="/login">Logout</a>
  </div>

Отображение XHTML
-----------------

Xitrum отображает представления как XHTML автоматически. Допускается делать
это самостоятельно:

::

  import scala.xml.Xhtml

  val br = <br />
  br.toString            // => <br></br>, some browsers will render this as 2 <br />s
  Xhtml.toXhtml(<br />)  // => "<br />"
