targetScope = 'resourceGroup'

param location string
param env string 
param prefix string
param tags object
param storageIPWhiteLists array
param sqlIPWhiteLists array 
param AdminGroupName string
param AdminGroupObjectID string 
@allowed([
  'LRS'
  'GRS'
])
param sqlPoolBackupType string
param sqlPooldwu string

var storageName = '${prefix}-dls-${env}'
var filesystems = [
  'workspace'
  'data'
  'raw'
  'enrich'
  'curate'
  'landing'
]

var synapseName = '${prefix}-syn-${env}'

var sparkName = 'spark001'
var sqlPoolName = 'dwh001'

var keyvaultName = '${prefix}-akv-${env}'

module storage 'services/storage.bicep'= {
  name: storageName
  params: {
    fileSystemNames: filesystems
    isHnsEnabled: true
    location: location
    storageIPWhiteLists: storageIPWhiteLists
    storageName: storageName
    tags:tags
    isNeedResourceAccessRules:true
  }
}

module synapse 'services/synapse.bicep' = {
  name: synapseName
  params: {
    location: location
    tags:tags
    sparkPoolName: sparkName
    synapseDefaultStorageAccountFileSystemId: storage.outputs.storageFileSystemIds[0].storageFileSystemId
    synapseName: synapseName
    AllowAzure:false
    ipWhiteLists:sqlIPWhiteLists
    synapseSqlAdminGroupName:AdminGroupName
    synapseSqlAdminGroupObjectID:AdminGroupObjectID
    sqlPoolBackupType:sqlPoolBackupType
    sqlPooldwu:sqlPooldwu
    sqlPoolName:sqlPoolName
  }
}

module keyvault  'services/keyvault.bicep' = {
  name: keyvaultName
  params: {
    tags:tags
    ipRules: storageIPWhiteLists
    keyvaultName: keyvaultName
    location: location
  }
}

module iam 'auxiliary/RoleAssignment.bicep' = {
  name: 'iam'
  params: {
    groupObjectId:AdminGroupObjectID 
    storageAccountId: storage.outputs.storageId
    synapseId: synapse.outputs.synapseId
    keyvaultId:keyvault.outputs.keyvaultId
  }
}
