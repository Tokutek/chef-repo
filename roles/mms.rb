name "mms"
description "agent process for mongo monitoring service"
override_attributes(
  "mongodb" => {
    "mms_agent" => {
      "api_key" => "255f9b85201a9f3be6cdad4ba6ee7d88"
    }
  }
)
run_list(
  "recipe[apt]",
  "recipe[mongodb::mms_monitoring_agent]"
)
