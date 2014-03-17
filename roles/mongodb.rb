name "mongodb"
description "stand-alone vanilla mongodb instance"
run_list(
    "recipe[mongodb::10gen_repo]",
    "recipe[apt]",
    "recipe[mongodb]"
)
