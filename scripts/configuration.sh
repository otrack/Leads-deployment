#!/bin/bash

USER="psutra"
PASSWORD="aaaa1111"
SSHCMDHEAD="ssh -l ${USER} clusterinfo.unineuchatel.ch"
SSHCMDNODE="ssh -l root -i id_rsa"
ID_DATASTORE="100"

# We partition the nodes in ${nuclouds} uclouds.
# All the resulting uclouds are stored in $uclouds, e.g., ${uclouds[0]} contains the first ucloud.
# The parameters below are also used by deploy-netem.sh and undeploy-netem.sh

${SSHCMDHEAD} "onevm list --user ${USER} --password ${PASSWORD} | grep ${USER} | gawk '{print \"onevm show --user ${USER} --password ${PASSWORD} \" \$1}'| sh | grep vnet | gawk '{result=\$5; while(getline){result=result\" \"\$5} print result}'" >> /tmp/nodes
nod=`cat /tmp/nodes`
rm -f /tmp/nodes # FIXME
IFS=' ' read -a nodes <<<  "${nod}"
nnodes=${#nodes[@]}

nuclouds="3"
let nodesPerUcloud=$nnodes/$nuclouds
if [[ $nodesPerUcloud*$nuclouds -ne $nnodes ]]
then
    echo "invalid number of uclouds"
    exit -1
fi

for g in `seq 1 ${nuclouds}`
do
    let begin=($g-1)*${nodesPerUcloud}
    let end=$g*${nodesPerUcloud}-1
    for i in `seq ${begin} ${end}`
    do
	if [[ $i -eq ${begin} ]]
	then
	    ucloud=(${nodes[$i]})
	else
	    ucloud=("`echo $ucloud` ${nodes[$i]}")
	fi
    done
    uclouds[$g-1]=$ucloud
done

delay="1" # inter-ucloud delay
rate="1000000"  # in kilo bits per seconds

