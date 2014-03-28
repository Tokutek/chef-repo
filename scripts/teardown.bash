pattern="$1"
if [ -z $pattern ] ; then
    echo "please specify a search pattern"
    exit 1
fi
acceptable_api_key="esmet" # don't want to accidentally nuke other's instances
node_tuples=$(knife ec2 server list | grep $acceptable_api_key | awk '($2 ~ /'$pattern'/ && $0 !~ /stopped|terminated/) { printf "%s,%s\n", $1, $2 }')
for tuple in $node_tuples; do
    IFS=","
    set $tuple
    instance_id="$1"
    node="$2"
    echo -n "Tearing down $node... "
    sudo knife ec2 server delete -y --purge --node-name $node $instance_id &>/dev/null
    if [ $? != 0 ] ; then
        echo "Failed to tear down $node with id $instance_id, proceeding anyway..."
    fi
    echo "ok"
done
