name "tokumx_configserver_edelight"
description "tokumx sharding config server"

override_attributes(
  "mongodb" => {
    "user" => "tokumx",
    "group" => "tokumx",
    "package_name" => "tokumx",
    "syslog" => "false",
    "config" => {
      "dbpath" => "/mnt/tokumx_data",
      "logpath" => "/var/log/tokumx/tokumx.log",
    },
    "dbconfig_file" => "/etc/tokumx.conf",
    "cluster_name" => "cluster0",
    "instance_name" => "tokumx",
    "default_init_name" => "tokumx",
  }
)

run_list(
  "recipe[apt]",
  "recipe[mongodb::tokutek_repo]",
  "recipe[mongodb::configserver]"
)
