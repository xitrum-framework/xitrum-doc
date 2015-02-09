XML
===

Scala cho phép viết literal XML. Xitrum sử dụng tính năng này như "template engine":

* Scala check cú pháp XML khi compile: Các View là typesafe.
* Scala tự động bỏ qua XML: Các view ngăn chặn `XSS <http://en.wikipedia.org/wiki/Cross-site_scripting>`_.

Dưới đây là một vài thủ thuật.

Unescape XML
------------

Sử dụng ``scala.xml.Unparsed``:

::

  import scala.xml.Unparsed

  <script>
    {Unparsed("if (1 < 2) alert('Xitrum rocks');")}
  </script>

hoặc sử dụng ``<xml:unparsed>``:

::

  <script>
    <xml:unparsed>
      if (1 < 2) alert('Xitrum rocks');
    </xml:unparsed>
  </script>

``<xml:unparsed>`` sẽ được ẩn đi trong output.

::

  <script>
    if (1 < 2) alert('Xitrum rocks');
  </script>

Các nhóm XML element
--------------------

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

``<xml:group>`` sẽ được ẩn đi trong output, ví dụ khi người dùng thực hiện đăng nhập:

::

  <div id="header">
    <b>My username</b>
    <a href="/login">Logout</a>
  </div>

Render XHTML
------------

Xitrum tự động render view và layout như XHTML. 
Nếu bạn muốn tự render chúng (hiếm khi), chú ý đến các dòng code dưới đây.

::

  import scala.xml.Xhtml

  val br = <br />
  br.toString            // => <br></br>, một vài trình duyệt sẽ render dòng này như 2 thẻ <br />
  Xhtml.toXhtml(<br />)  // => "<br />"

