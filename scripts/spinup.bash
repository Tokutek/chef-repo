if [ -z $NUM_SHARDS ] ; then
    echo "Defaulting to 1 shard"
    NUM_SHARDS=1
fi
if [ -z $NUM_RS_MEMBERS ] ; then
    echo "Defaulting to 1 member replica sets"
    NUM_RS_MEMBERS=1
fi

template_role='{
  "name": "ROLE_TEMPLATE_ROLE_NAME",
  "description": "tokumx replica-set member in a sharded cluster",
  "json_class": "Chef::Role",
  "default_attributes": {
  },
  "override_attributes": {
    "mongodb": {
      "user": "tokumx",
      "group": "tokumx",
      "package_name": "tokumx",
      "syslog": "false",
      "config": {
        "dbpath": "/mnt/tokumx_data",
        "logpath": "/var/log/tokumx/tokumx.log",
        "replSet": "ROLE_TEMPLATE_REPLSET"
      },
      "dbconfig_file": "/etc/tokumx.conf",
      "cluster_name": "cluster0",
      "shard_name": "ROLE_TEMPLATE_SHARD_NAME",
      "instance_name": "tokumx",
      "default_init_name": "tokumx"
    }
  },
  "chef_type": "role",
  "run_list": [
    "recipe[apt]",
    "recipe[mongodb::tokutek_repo]",
    "recipe[mongodb::replicaset]",
    "recipe[mongodb::shard]"
  ],
  "env_run_lists": {
  }
}'

echo "staring: shards = $NUM_SHARDS, num replica set members = $NUM_RS_MEMBERS"
cluster_name="cluster0" # MAGIC - must match the cluster name in the template above
configserver_node_name="${cluster_name}_config0"
mongos_node_name="${cluster_name}_mongos0"
role_prefix="${cluster_name}_tokumx_shard"

# create a role for each shard, changing the necessary template tokens
role_dir="/tmp/$(basename $0).$$.tmp"
(rm -rf $role_dir && mkdir -p $role_dir) || exit 2
for shard_num in $(seq 0 $((NUM_SHARDS - 1))) ; do
    role_name="${role_prefix}${shard_num}"
    shard_name="shard${shard_num}"

    echo "-- creating role file, role name $role_name, shard name $shard_name"
    role_file="${role_dir}/${role_name}.json"
    echo $template_role                                     \
        | sed "s/ROLE_TEMPLATE_ROLE_NAME/$role_name/g"      \
        | sed "s/ROLE_TEMPLATE_SHARD_NAME/$shard_name/g"    \
        | sed "s/ROLE_TEMPLATE_REPLSET/rs_$shard_name/g"    \
        > $role_file
done

# import all of the roles
echo "importing roles from $role_dir"
knife role from_file $role_dir/*.json
if [ $? != 0 ] ; then
    echo "Failed to create roles in directory $role_dir"
    exit 1
fi
rm -rf $role_dir

node_list="$(knife node list)"

# spinup an ec2 node with a given node name unless one already exists
function ec2_spinup {
    node_name="$1"
    run_list="$2"

    if echo $node_list | grep "$node_name" &>/dev/null ; then
        echo "---- (ec2_spinup) a node named $node_name already exists, skipping."
        return 0
    else
        echo "-- spinning up node $node_name with run list $run_list"
    fi

    image="ami-013f9768"
    zone="us-east-1e"
    flavor="m1.small"
    sudo knife ec2 server create                    \
        --availability-zone "$zone"                 \
        --flavor "$flavor"                          \
        --image "$image"                            \
        --identity-file ~/esmet.pem                 \
        --run-list "$run_list"                      \
        --node-name "$node_name"                    \
        --ssh-user ubuntu >/dev/null
    if [ $? == 0 ] ; then
        echo "-- successfully created node $node_name"
    else
        echo "-- failed to create node $node_name"
    fi
}

# spin up a config server
ec2_spinup $configserver_node_name "role[tokumx_configserver]"
if [ $? != 0 ] ; then
    echo "Failed to spin up config server"
    exit 1
fi

function spinup_replset_shard {
    shard_num=$1
    for rs_member_num in $(seq 0 $((NUM_RS_MEMBERS - 1))) ; do
        node_name="${cluster_name}_shard${shard_num}_rs${rs_member_num}"
        run_list="role[${role_prefix}${shard_num}]"

        ec2_spinup "$node_name" "$run_list"
        if [ $? != 0 ] ; then
            echo "Failed to spin up node ${node_name}"
            exit 1
        fi
    done
}

# spin up each replset as an async task
for shard_num in $(seq 0 $((NUM_SHARDS - 1))) ; do
    spinup_replset_shard "$shard_num" &
done

# spin up a mongos
ec2_spinup $mongos_node_name "role[tokumx_mongos]"
if [ $? != 0 ] ; then
    echo "Failed to spin up mongos ${mongos_node_name}"
    exit 1
fi
