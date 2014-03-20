name "tokumx_replicaset_hidden"
description "hidden node in a replica set"

override_attributes(
  "mongodb" => {
    "user" => "tokumx",
    "group" => "tokumx",
    "distro" => "tokumx",
    "package_name" => "tokumx",
    "syslog" => "false",
    "data_dir" => "/mnt/tokumx_data",
    "mongod" => {
      "hidden" => true,
      "priority" => 0,
      "votes" => 0
    }
  },
)

run_list(
  "recipe[apt]",
  "recipe[mongodb::tokutek_repo]",
  "recipe[hipsnip-mongodb::replica_set]"
)
