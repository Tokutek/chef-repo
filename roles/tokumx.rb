name "tokumx"
description "stand-alone tokumx instance"

override_attributes(
    mongodb: {
        package_name: 'tokumx'
    }
)

run_list(
    "recipe[apt]",
    "recipe[mongodb::tokutek_repo]",
    "recipe[mongodb]"
)
