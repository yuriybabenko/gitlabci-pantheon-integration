#!/bin/bash

# Store the mr- environment name
export PANTHEON_ENV=mr-$CI_MERGE_REQUEST_IID

# Authenticate with Terminus
terminus auth:login --machine-token=$PANTHEON_MACHINE_TOKEN

# Push the merge request source branch to Pantheon
git push pantheon $CI_COMMIT_REF_NAME:$PANTHEON_ENV --force

# Create a function for determining if a multidev exists
TERMINUS_DOES_MULTIDEV_EXIST()
{
    # Stash a list of Pantheon multidev environments
    PANTHEON_MULTIDEV_LIST="$(terminus multidev:list ${PANTHEON_SITE} --format=list --field=id)"

    while read -r multiDev; do
        if [[ "${multiDev}" == "$1" ]]
        then
            return 0;
        fi
    done <<< "$PANTHEON_MULTIDEV_LIST"

    return 1;
}

# If the mutltidev doesn't exist
if ! TERMINUS_DOES_MULTIDEV_EXIST $PANTHEON_ENV
then
    # Create it with Terminus
    echo "Creating new Multidev environment: $PANTHEON_ENV"
    terminus multidev:create $PANTHEON_SITE.dev $PANTHEON_ENV
    echo "Code deployed to new Multidev environment: $PANTHEON_ENV"
else
    echo "Code deployed to existing Multidev environment: $PANTHEON_ENV"
fi
