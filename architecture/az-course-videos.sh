#!/bin/bash

# This script automates the creation of MS Azure resources needed to store lecture videos from the 
# Software Architecture in Practice (Bass) textbook. 
#

resourceGroupName="course-videos-rg"
storageAccountName="coursevideos"
videosContainerName="bass"
location="centralus"

# Implement help with examples for "--help", "-h", or no arguments.
if [ "$1" = "--help" -o "$1" = "-h" -o $# -eq 0 ]; then
    scriptFileName=${0##*/}
    echo
    echo "Overview:"
    echo "This script creates the MS Azure Resource Group and Container to store course videoes"
    echo
    echo "Example Usage:"
    echo "bash $scriptFileName --create-resource-group-and-storage-account"
    echo "bash $scriptFileName --create-container"
    echo "bash $scriptFileName --upload-file [FileName] [RemoteFileName]"
    echo "bash $scriptFileName --list-files"
    echo "bash $scriptFileName --list-blob-properties [FileName]"
    echo "bash $scriptFileName --verify-file [FileName]"
    echo "bash $scriptFileName --verify-all-files"
    echo
    exit 0
fi

function setStorageAccountConnectionString() {
    connectionString=$(az storage account show-connection-string \
        --name $storageAccountName \
        --resource-group $resourceGroupName \
        --query connectionString -o tsv)
    export AZURE_STORAGE_CONNECTION_STRING=$connectionString
}

if [ "$1" = "--create-resource-group-and-storage-account" ]; then
    echo
    echo "Creating resource group: $resourceGroupName"
    az group create \
        --name $resourceGroupName \
        --location centralus 
    echo

    echo "Creating storage account: $storageAccountName"
    az storage account create \
        --name $storageAccountName \
        --resource-group $resourceGroupName \
        --location $location \
        --sku Standard_LRS 
    echo
fi

if [ "$1" = "--create-resource-group-and-storage-account" ]; then
    setStorageAccountConnectionString

    echo "Creating container: $videosContainerName"
    az storage container create \
        --name $videosContainerName \
        --public-access blob
fi

function uploadFile() {
    local fileName=$1
    local remoteFileName=$2

    if [ -z "$remoteFileName" ]; then 
        remoteFileName=$fileName
    fi
    echo "Uploading $fileName to $remoteFileName"

    setStorageAccountConnectionString
    az storage blob upload \
        --container-name $videosContainerName \
        --file $fileName \
        --name $remoteFileName
}

if [ "$1" = "--upload-file" -o "$1" = "-upload" -o "$1" = "-u" ]; then
    fileName=$2
    remoteFileName=$3
    uploadFile $fileName $remoteFileName
fi

if [ "$1" = "--list-files" -o "$1" = "-lf" ]; then
    setStorageAccountConnectionString
    az storage blob list --container-name $videosContainerName --output table
fi

if [ "$1" = "--list-blob-properties" -o "$1" = "-bp" ]; then
    fileName=$2
    setStorageAccountConnectionString
    az storage blob show -c $videosContainerName -n $fileName --output table
fi

function verifyFile() {
    fileName=$1

    setStorageAccountConnectionString
    fileExistsInAzure=$(az storage blob exists --container-name $videosContainerName --name $fileName --query 'exists')

    # Magic constants for printing red and no color text.
    RED='\033[0;31m'
    NC='\033[0m' 
    if [ "$fileExistsInAzure" = "true" ]; then
        printf "$fileName"
    else 
        printf "${RED}$fileName...Failed (does not exist in Azure)${NC}\n"
        return
    fi

    localFileSize=$(stat -f%z "$fileName")
    # Consider adding date modified check later:
    #     localModified=$(stat -f%m "$fileName")
    remoteFileSize=$(az storage blob show -c $videosContainerName -n $fileName --query 'properties.contentLength')

    if [ "$localFileSize" = "$remoteFileSize" ]; then
        printf "...Passed\n"
    else 
        printf "${RED}...Failed (does not have the same file size $localFileSize/$remoteFileSize)${NC}\n"
    fi
}

if [ "$1" = "--verify-file" -o "$1" = "-vf" ]; then
    fileName=$2
    verifyFile $fileName
fi

if [ "$1" = "--verify-all-files" -o "$1" = "-va" ]; then
    for file in *.mp4
    do
        verifyFile $file
    done

    for file in *.pptx
    do
        verifyFile $file
    done
fi


