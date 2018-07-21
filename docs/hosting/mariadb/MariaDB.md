```mysql-conf
table_open_cache = 16384
table_definition_cache = 8192

sort_buffer_size = 256K

read_buffer_size = 128K

read_rnd_buffer_size = 256K

myisam_sort_buffer_size = 64M
myisam_use_mmap = 1
thread_concurrency = 10
wait_timeout = 30

myisam-recover = BACKUP,FORCE

query_cache_limit = 10M
query_cache_size = 1024M
query_cache_type = 1

join_buffer_size = 4M

log_slow_queries = /var/log/mysql/mysql-slow.log
long_query_time = 1

expire_logs_days = 10
max_binlog_size = 100M

innodb_buffer_pool_size = 2048M
innodb_log_file_size = 256M
innodb_log_buffer_size = 16M
innodb_flush_log_at_trx_commit = 0
innodb_thread_concurrency = 8
innodb_read_io_threads = 64
innodb_write_io_threads = 64
innodb_io_capacity = 50000
innodb_flush_method = O_DIRECT
innodb_file_per_table
innodb_additional_mem_pool_size = 256M
transaction-isolation = READ-COMMITTED

innodb_support_xa = 0
innodb_commit_concurrency = 8
innodb_old_blocks_time = 1000
[...]
```

Beachten Sie bitte: Benötigen Sie ACID Konformität müssen Sie innodb_flush_log_at_trx_commit auf 1 setzen. Hier können Sie mehr darüber herausfinden: http://dev.mysql.com/doc/refman/5.5/en/innodb-parameters.html#sysvar_innodb_flush_log_at_trx_commit.

`innodb_io_capacity` sollte nur auf einen hohen Wert gesetzt werden wenn Sie MySQL auf einer SSD benutzen. Benutzen Sie es auf einer normalen Festplatte, lassen Sie diese Zeile besser aus.

#### Benutzung einer SSD

Ein riesiger Leistungsboost ist möglich wenn Sie MySQL mit einer Solid State Disk (SSD) benutzen, da dies die Disk I/O stark verringert. Der einfachste Weg dies zu erreichen ist, das /var/lib/mysql Verzeichnis auf einer SSD zu mounten.