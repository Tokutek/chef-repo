name "tokumx_replicaset"
description "tokumx replica-set member"

override_attributes(
  "mongodb" => {
    "user" => "tokumx",
    "group" => "tokumx",
    "package_name" => "tokumx",
    "syslog" => "false",
    "config" => {
      "dbpath" => "/mnt/tokumx_data",
      "logpath" => "/var/log/tokumx/tokumx.log",
      "replSet" => "replicaset0"
    },
    "dbconfig_file" => "/etc/tokumx.conf",
    "cluster_name" => "cluster0",
    "shard_name" => "shard0",
    "instance_name" => "tokumx",
    "default_init_name" => "tokumx"
  }
)

run_list(
  "recipe[apt]",
  "recipe[tokumx::tokutek_repo]",
  "recipe[mongodb::replicaset]"
)
