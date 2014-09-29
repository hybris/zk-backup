# <a name="backup"></a>Zookeeper-Backup

To have the Zookeeper backed up regularly we have created a Go program that does backups automatically.
You will find the source code at `src/zk-backyp`.

## How does it work?
Zookeeper is an in-memory, distributed, non-sharded, consistent, fault-tolerant database. That means, on every node you have the same information. When one node fails its workload will be transferred to another node. You will get a higher latency for a moment but no query should get lost. All data is held in memory and is written to a transaction log on disk. From time to time a complete snapshot of the in-memory data is written to a snapshot file. The next transaction log starts from this snapshot.
We use this characteristic to implement a backup mechanism:

1. Shut down one Zookeeper node (other Zookeeper nodes will jump in and do its job, while it is down)
2. tar czf snapshots and their incrementing transaction logs
3. Restart the Zookeeper node
4. Upload the backup .tar.gz to S3
5. Delete the backup .tar.gz from local disk

###The Backup process runs only on ONE Zookeeper node!

To deploy the ZK-Backyp programm on an instance, add the zk-backyp template to a job in your deployment manifest. e.g.:

    jobs:
      - name: kafka_zookeeper_prod_us-east-1c
        instances: 1
        templates:
          - name: zookeeper
            release: zookeeper-hybris
          - name: zk-backyp
            release: zookeeper-hybris
        ...

Further you have to set some properties to configure the backup name (built from prefix + datestring + .tar.gz), backup interval in seconds (default 86400 seconds = 1 day) as well as the S3 target.

    properties:
      zk_backyp:
        prefix: zookeeper-backup-eu-west1-staged
        interval: 86400
        s3_bucket: zookeeper-backup.cf2.hybris.com
        s3_endpoint: https://s3-eu-west-1.amazonaws.com
        aws_access_key: AJHKJUAFH6FLFJKH5
        aws_secret_key: dhihfAFDSdh4j3FSFDAFh35j4lFAD/jklhl43fe
