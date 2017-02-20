Metrics
=======

Xitrum thu thập thông tin bộ nhớ JVM heap, CPU, và tình trạng thực thi của các action từ mỗi node
trong Akka cluster của ứng dụng. Nó xuất ra các số liệu trong định dạng dữ liệu JSON. Xitrum cũng
cho phép bạn thu thập cách các dữ liệu khác.

Công cụ metrics này dựa theo thư viện `Coda Hale Metrics <http://metrics.dropwizard.io/3.1.0/>`_.

Thu thập thông tin
------------------

Bộ nhớ heap và CPU
~~~~~~~~~~~~~~~~~~

Bộ nhớ JVM heap và CPU sẽ được thu thập
`NodeMetrics <http://doc.akka.io/api/akka/2.3.0/index.html#akka.cluster.NodeMetrics>`_
từ mỗi node của hệ thống Akka actor.

Bộ nhớ heap:

.. image:: ../img/metrics_heapmemory.png


CPU: số lượng tiến trình và tải trung bình

.. image:: ../img/metrics_cpu.png

Action metric
~~~~~~~~~~~~~

Xitrum thu thập tình trạng thực thi các action của mỗi node như một
`Histogram <http://metrics.dropwizard.io/3.1.0/getting-started/#histograms>`_.
Bạn có thể biết chính các bao nhiêu lần action được thực thi và thời gian
thực thi của những non-async action.

.. image:: ../img/metrics_action_count.png


Thời gian thực hiện lần gần nhất của một action:

.. image:: ../img/metrics_action_time.png

Thu thập các số liệu tùy chỉnh
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Ngoài các số liệu mặc định nêu trên, bạn có thể thu thập các dữ liệu cho riêng mình.
``xitrum.Metrics`` có thể truy cập vào ``gauge``, ``counter``, ``meter``,
``timer`` và ``histogram``. Vui lòng tham khảo
`Coda Hale Metrics <http://metrics.dropwizard.io/3.1.0/>`_ và
`bản hiện thực Scala của nó <https://github.com/erikvanoosten/metrics-scala>`_
để biết cách sử dụng.

Ví dụ về timer:

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
        // Something that you want to measure execution time
        ...
      }
      ...
    }
  }

Xuất ra các metric
------------------

Xitrum xuất ra giá trị mới nhất của metric dưới định đạng JSON sau một chu kỳ
xác định.
Các dữ liệu thu thập được có nhiều biến động, sẽ không được lưu trữ vĩnh viễn

HeapMemory:

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


CPU:

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

MetricsRegistry sẽ được phân tách bởi
`metrics-json <http://metrics.dropwizard.io/3.1.0/manual/json/>`_.

Xitrum viewer mặc định
~~~~~~~~~~~~~~~~~~~~~~

Xitrum cung cấp metric viewer mặc định tại URL ``/xitrum/metrics/viewer?api_key=<see xitrum.conf>``.
URL này hiển thị các đồ thị như trên. Các đồ thị được tạo bởi `D3.js <http://d3js.org/>`_.

URL có thể được tạ ra với:

::

  import xitrum.Config
  import xitrum.metrics.XitrumMetricsViewer

  url[XitrumMetricsViewer]("api_key" -> Config.xitrum.metrics.get.apiKey)

Jconsole viewer
~~~~~~~~~~~~~~~

Bạn có thể xem nó với `JVM Reporter <http://metrics.dropwizard.io/3.1.0/getting-started/#reporting-via-jmx>`_.

.. image:: ../img/metrics_jconsole.png

Khởi động JMX reporter:

::

  import com.codahale.metrics.JmxReporter

  object Boot {
    def main(args: Array[String]) {
      Server.start()
      JmxReporter.forRegistry(xitrum.Metrics.registry).build().start()
    }
  }

Sau đó chạy `jconsole <http://docs.oracle.com/javase/7/docs/technotes/guides/management/jconsole.html>`_ command.

Hiển thị metiric với custom viewer
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Metric sẽ được xuất ra tại SockJS URL ``xitrum/metrics/channel`` như JSON.
``jsAddMetricsNameSpace`` là một JavaScript snippet mà Xitrum cung cấp để tạo
kết nối.

Sử dụng JSON handler của bạn và gọi ``initMetricsChannel`` với handler đó.

Ví dụ về action:

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

Lưu metric
~~~~~~~~~~

Để tiết kiệm bộ nhớ, Xitrum không ghi nhớ các giá trị metric cũ. Nếu bạn muốn lưu metric vào
cơ sở dữ liệu hoặc tập tin nào đó, bạn cần implement vào subscriber của bạn.

Ví dụ:

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
