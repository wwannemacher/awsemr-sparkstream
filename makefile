# make sure that you have ~/.aws/credentials, ~/.aws/config and a named profile
#   e.g. export AWS_PROFILE=myprofile
#
# make sure you have a pre-existing private key for new instances
#   e.g. export AWS_KEY_NAME=sandbox
#   e.g. export AWS_KEY=~/.ec2/$AWS_KEY_NAME.pem
#
# after create_cluster, set the cluster id and ip
#   e.g. export EMR_MASTER=myclusterip
#   e.g. export EMR_CLUSTER_ID=myclusterid

EMR_CLUSTER_NAME=emr-spark-cluster
EMR_RELEASE_LABEL=emr-4.3.0
EMR_INSTANCE_TYPE=m3.xlarge
EMR_INSTANCE_COUNT=3
EMR_OPTIONS=--applications Name=Spark --use-default-roles
create_cluster:
	aws emr create-cluster --profile ${AWS_PROFILE} --name "$(EMR_CLUSTER_NAME)" --release-label $(EMR_RELEASE_LABEL)  --ec2-attributes KeyName=${AWS_KEY_NAME} --instance-type $(EMR_INSTANCE_TYPE) --instance-count $(EMR_INSTANCE_COUNT) $(EMR_OPTIONS)

list_clusters:
	aws emr --profile ${AWS_PROFILE} list-clusters

list_instances:
	aws emr --profile ${AWS_PROFILE} list-instances --cluster-id ${EMR_CLUSTER_ID}

connect:
	ssh -i $(AWS_KEY) hadoop@${EMR_MASTER}


## spark - batching (via spark-shell)
#
# line count
batch_line_count:
	val textFile = sc.textFile("s3://elasticmapreduce/samples/hive-ads/tables/impressions/dt=2009-04-13-08-05/ec2-0-51-75-39.amazon.com-2009-04-13-08-05.log")
	val comCount = textFile.filter(line => line.contains(".com")).count()

## spark - streaming (via spark-shell)
#
stream_word_count:
	# stop existing context
	sc.stop()
	# create new context
	< src/main/scala/SparkStreamingContext.scala
	# start counting words in batches
	< src/main/scala/SparkStreamingCount.scala
	# start the computation and wait for termination
	ssc.start()             // Start the computation
	ssc.awaitTermination()  // Wait for the computation to terminate

# client - direct network send of streaming text via netcat..
stream_client:
	nc -lk 9999
