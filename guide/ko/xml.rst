XML
===

Scala는 리터럴 문자를 표시할 수 있습니다. Xitrum에서는 이 기능을 템플릿 엔진으로 사용하고 있습니다.

* Scala는 XML 구문을 컴파일 때 체크합니다: View는 typesafe합니다.
* Scala는 XML의 자동적으로 이스케이프하여 `XSS <http://en.wikipedia.org/wiki/Cross-site_scripting>`_　공격을 방지합니다.

일부 팁이 있습니다.

XML의 이스케이프
-------------

``scala.xml.Unparsed`` 를 사용하는 경우:

::

  import scala.xml.Unparsed

  <script>
    {Unparsed("if (1 < 2) alert('Xitrum rocks');")}
  </script>

``<xml:unparsed>`` 를 사용하는 경우:

::

  <script>
    <xml:unparsed>
      if (1 < 2) alert('Xitrum rocks');
    </xml:unparsed>
  </script>

``<xml:unparsed>`` 는 실제 출력에 포함되지 않습니다:

::

  <script>
    if (1 < 2) alert('Xitrum rocks');
  </script>

XML 요소의 그룹화
--------------

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

``<xml:group>`` 는 실제 출력에 포함되지 않습니다. 예를 들어 사용자가 로그인한 경우:

::

  <div id="header">
    <b>My username</b>
    <a href="/login">Logout</a>
  </div>


XHTML 렌더링
-----------

Xitrum은 view 와 레이아웃을 자동으로 XHTML로 출력합니다.
이것을 직접 출력으로 표시할경우 드믈지만 다음 코드가 나타나는 것을 주의하세요.

::

  import scala.xml.Xhtml

  val br = <br />
  br.toString            // => <br></br>, 이 경우에 브라우저는 br태그가 두 개 있다고 판단합니다.
  Xhtml.toXhtml(<br />)  // => "<br />"
