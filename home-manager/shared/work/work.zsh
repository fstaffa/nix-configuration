#!/usr/bin/env zsh

function _stskeygen_helper {
    stskeygen --account $1 --profile $1 --admin --duration 43200
}

function aws-planning {
    _stskeygen_helper logisticsquotingplanning
}

function aws-praguematic {
    _stskeygen_helper praguematic
}

function aws-sapidus {
    _stskeygen_helper sapidus
}

AWS_PROFILE=logisticsquotingplanning@admin

function bastion_key {
    SSH_KEY_FILE=~/.ssh/bastion_connect
    rm $SSH_KEY_FILE*
    ssh-keygen -t rsa -b 2048 -f $SSH_KEY_FILE -q -N ""
    instance_id=`aws ec2 describe-instances --filter Name=tag:Name,Values=Bastion Name=instance-state-name,Values=running --query 'Reservations[*].Instances[*].{Instance:InstanceId}' --output text`
    echo $instance_id
    aws ec2-instance-connect send-ssh-public-key --region eu-west-1 --instance-os-user ec2-user --ssh-public-key file://$SSH_KEY_FILE.pub --availability-zone eu-west-1a --instance-id $instance_id
}

function set_ccm_test_keys {
    E2E_SECRET=$(aws secretsmanager get-secret-value --profile logisticsquotingplanning --secret-id test/ccm/e2e-client | jq ".SecretString | fromjson")
    export E2E_CLIENT_ID=$(echo $E2E_SECRET | jq -r '.id')
    export E2E_CLIENT_SECRET=$(echo $E2E_SECRET | jq -r '.secret')
}

function set_shipcalc_db_keys {
    SECRET_NAME=production/shipcalc/db-app-user
    SECRET=$(aws secretsmanager get-secret-value --profile logisticsquotingplanning --secret-id $SECRET_NAME | jq ".SecretString | fromjson")
    export DATABASE__USER=$(echo $SECRET | jq -r '.username')
    export DATABASE__PASSWORD=$(echo $SECRET | jq -r '.password')
}
