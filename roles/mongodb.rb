name "mongodb"
description "stand-alone mongodb instance"
run_list(
    "recipe[apt]",
    "recipe[mongodb::default]"
)
