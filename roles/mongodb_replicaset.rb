name "mongodb_replicaset"
description "stand-alone vanilla mongodb instance"
run_list(
    "recipe[apt]",
    "recipe[mongodb::replicaset]"
)
