// via http://spark.apache.org/docs/latest/streaming-programming-guide.html
//
import org.apache.spark._
import org.apache.spark.streaming._
import org.apache.spark.streaming.StreamingContext._

// create a local StreamingContext with two working thread and batch interval of 10 seconds.
// The master requires 2 cores to prevent from a starvation scenario.
val conf = new SparkConf().setMaster("local[2]").setAppName("NetworkWordCount")
val ssc = new StreamingContext(conf, Seconds(10))

// create a dstream and split map
// Create a DStream that will connect to hostname:port, like localhost:9999
val lines = ssc.socketTextStream("localhost", 9999)

// split each line into words
val words = lines.flatMap(_.split(" "))
