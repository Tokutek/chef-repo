name "tokumx"
description "stand-alone mongodb instance"
run_list(
    "recipe[tokumx::tokutek_repo]",
    "recipe[apt]",
    "recipe[tokumx]"
)
