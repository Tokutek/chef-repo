name "tokumx_mongos"
description "tokumx mongos router"

override_attributes(
  "mongodb" => {
    "user" => "tokumx",
    "group" => "tokumx",
    "package_name" => "tokumx",
    "config" => {
      "logpath" => "/var/log/tokumx/tokumx.log"
    },
    "cluster_name" => "cluster0",
    "dbconfig_file" => "/etc/tokumx.conf",
    "instance_name" => "mongos",
    "default_init_name" => "mongos"
  }
)

run_list(
  "recipe[apt]",
  "recipe[mongodb::tokutek_repo]",
  "recipe[mongodb::mongos]",
)
