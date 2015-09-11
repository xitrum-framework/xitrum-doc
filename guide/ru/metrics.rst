Метрики
=======

Xitrum собирает информацию об использовании памяти, CPU и информацию об использовании
контроллеров каждой ноды вашего Akka кластера. Эти данные публикуются в JSON формате.
Xitrum так же позволяет публиковать ваши метрики.

Эти метрики базируются на библиотеке `Coda Hale Metrics <http://metrics.dropwizard.io/3.1.0/>`_.

Агрегирование метрик
--------------------

Память и CPU
~~~~~~~~~~~~

Информация по памяти и CPU собирается с помощью
`NodeMetrics <http://doc.akka.io/api/akka/2.3.0/index.html#akka.cluster.NodeMetrics>`_
системы актров каждой ноды.

Память:

.. image:: ../img/metrics_heapmemory.png


CPU: Количество процессоров и средняя загрузка

.. image:: ../img/metrics_cpu.png

Метрики контроллера
~~~~~~~~~~~~~~~~~~~

Xitrum собирает состояния выполнения каждого контроллера в формате
`гистограммы <http://metrics.dropwizard.io/3.1.0/getting-started/#histograms>`_.
Вы можете узнать сколько раз контроллер запускался, время выполнения для
не асинхронных запросов.

.. image:: ../img/metrics_action_count.png

Последнее время выполнения конкретного контроллера:

.. image:: ../img/metrics_action_time.png

Дополнительные метрики
~~~~~~~~~~~~~~~~~~~~~~

Дополнительные метрики вы можете собирать самостоятельно. Подробнее про использование читайте
`Coda Hale Metrics <http://metrics.dropwizard.io/3.1.0/>`_ и
`реализация на Scala <https://github.com/erikvanoosten/metrics-scala>`_. Используйте
пакет ``xitru.Metrics``, в нем ``gauge``, ``counter``, ``meter``, ``timer`` и ``histogram``.

Пример таймера:

::

  import xitrum.{Action, Metrics}
  import xitrum.annotation.GET

  object MyAction {
    lazy val myTimer = Metrics.timer("myTimer")
  }

  @GET("my/action")
  class MyAction extends Action {
    import MyAction._

    def execute() {
      myTimer.time {
        // Задача время выполнения которой вы хотите замерить
        ...
      }
      ...
    }
  }

Публикация метрик
-----------------

Xitrum публикует последние значения метрики в JSON формате через определенный интервал времени.
Этот интервал имеет не постоянное значение и может меняться.

Информация о памяти:

::

  {
    "TYPE"      : "heapMemory",
    "SYSTEM"    : akka.actor.Address.system,
    "HOST"      : akka.actor.Address.host,
    "PORT"      : akka.actor.Address.port,
    "HASH"      : akka.actor.Address.hashCode,
    "TIMESTAMP" : akka.cluster.NodeMetrics.timestamp,
    "USED"      : Number as byte,
    "COMMITTED" : Number as byte,
    "MAX"       : Number as byte
  }


Информация о CPU:

::

  {
    "TYPE"              : "cpu",
    "SYSTEM"            : akka.actor.Address.system,
    "HOST"              : akka.actor.Address.host,
    "PORT"              : akka.actor.Address.port,
    "HASH"              : akka.actor.Address.hashCode,
    "TIMESTAMP"         : akka.cluster.NodeMetrics.timestamp
    "SYSTEMLOADAVERAGE" : Number,
    "CPUCOMBINED"       : Number,
    "PROCESSORS"        : Number
  }

MetricsRegistry использует `metrics-json <http://metrics.dropwizard.io/3.1.0/manual/json/>`_ для разбора
JSON файла.

Просмотр метрик через Xitrum
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Xitrum предоставляет стандартный способ просмотра метрик по ссылке ``/xitrum/metrics/viewer?api_key=<смотри xitrum.conf>``.
По этой ссылке доступны графики представленные выше.
Графики созданы с использованием `D3.js <http://d3js.org/>`_.

Ссылка может быть сформирована следующим образом:

::

  import xitrum.Config
  import xitrum.metrics.XitrumMetricsViewer

  url[XitrumMetricsViewer]("api_key" -> Config.xitrum.metrics.get.apiKey)

Jconsole
~~~~~~~~

Метрики можно просматривать через ``jconsole`` используя `JVM Reporter <http://metrics.dropwizard.io/3.1.0/getting-started/#reporting-via-jmx>`_.

.. image:: ../img/metrics_jconsole.png

Запуск:

::

  import com.codahale.metrics.JmxReporter

  object Boot {
    def main(args: Array[String]) {
      Server.start()
      JmxReporter.forRegistry(xitrum.Metrics.registry).build().start()
    }
  }

Затем используйте `jconsole <http://docs.oracle.com/javase/7/docs/technotes/guides/management/jconsole.html>`_.

Просмотр метрик сторонними средствами
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Метрики публикуются как ссылка SockJS ``xitrum/metrics/channel`` в формате JSON.
``jsAddMetricsNameSpace`` - шаблон JavaScript кода который предоставляет Xitrum
для установки соединения.

Реализуйте свой собственный JSON обработчик используя метод ``initMetricsChannel``.

Пример контроллера:

::

  import xitrum.annotation.GET
  import xitrum.metrics.MetricsViewer

  @GET("my/metrics/viewer")
  class MySubscriber extends MetricsViewer {
    def execute() {
      jsAddMetricsNameSpace("window")
      jsAddToView("""
        function onValue(json) {
          console.log(json);
        }
        function onClose(){
          console.log("channel closed");
        }
        window.initMetricsChannel(onValue, onClose);
      """)
      respondView()
    }
  }

Хранения метрик
~~~~~~~~~~~~~~~

Для экономии памяти, Xitrum не хранит старые значения метрик. Если вы хотите хранить эти
значения, вам передается реализовать собственный обработчик.

Например:

::

  import akka.actor.Actor
  import xitrum.metrics.PublisherLookUp

  class MySubscriber extends Actor with PublisherLookUp {
    override def preStart() {
      lookUpPublisher()
    }

    def receive = {
      case _ =>
    }

    override def doWithPublisher(globalPublisher: ActorRef) = {
      context.become {
        // When run in multinode environment
        case multinodeMetrics: Set[NodeMetrics] =>
          // Save to DB or write to file.

        // When run in single node environment
        case nodeMetrics: NodeMetrics =>
          // Save to DB or write to file.

        case Publish(registryAsJson) =>
          // Save to DB or write to file.

        case _ =>
      }
    }
  }
