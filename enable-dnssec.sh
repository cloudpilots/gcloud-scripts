#!/bin/bash
# Enable DNSSec and display DS keys for all your projects
# Author CLOUDPILOTS <support@cloudpilots.com>

for project in $(gcloud projects list --format "value(projectId)" --filter "projectId~mycompany-.+")
do
    for zone in $(gcloud --project=$project dns managed-zones list --filter 'visibility=public' --format 'value(name)')
    do
        dnsName=$(gcloud --project=$project dns managed-zones describe $zone --format 'value(dnsName)')
        dnssecState=$(gcloud --project=$project dns managed-zones describe $zone --format 'value(dnssecConfig.state)')
        if [[ "$dnssecState" == "on" ]]; then
            echo "DNSSEC is enabled on zone $zone $dnsName in project $project"
        else
            echo "DNSSEC is disabled on zone $zone $dnsName in project $project, enabling it"
            gcloud --project=$project dns managed-zones update $zone --dnssec-state=on
            dsRecord=$(gcloud --project=$project dns dns-keys describe --zone=$zone 0 --format 'value(ds_record())')
            echo "new DS record for $dnsName"
            echo "$dnsName IN DS $dsRecord"
            echo
        fi
    done
done
