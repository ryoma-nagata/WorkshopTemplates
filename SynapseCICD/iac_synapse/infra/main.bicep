
targetScope = 'resourceGroup'

// general params

param location string = 'japaneast'

param project string 
@allowed([
  'demo'
  'poc'
  'dev'
  'test'
  'prod'
  'stg'
])
param env string 
param deployment_id string = '01'
param storageIPWhiteLists array =[
  {
  value: '*.*.*.*'
  action: 'Allow'
  }
]
param sqlIPWhiteLists array = [
  {
    name : 'sampleAllIp'
    startIpAddress:'0.0.0.0'
    endIpAddress:'255.255.255.255' 
  }
]
@description('セキュリティグループの名称を入力すると自動で権限が付与されます')
param AdminGroupName string = ''
@description('セキュリティグループのプリンシパルIDを入力すると自動で権限が付与されます')
param AdminGroupObjectID string 
@allowed([
  'LRS'
  'GRS'
])
param sqlPoolBackupType string = 'LRS'
param sqlPooldwu string = 'DW100c'

var prefix  = '${project}-${deployment_id}'

var tags = {
  Environment : env
  Project : project
}

// var rg_name = '${prefix}-rg-${env}'

// resource ProductResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01'={
//   name: rg_name
//   location: location
//   tags:tags
// }


module product 'modules/product.bicep' = {
  // scope: ProductResourceGroup
  name: 'product'
  params: {
    storageIPWhiteLists:storageIPWhiteLists
    env: env
    tags: tags
    prefix: prefix
    AdminGroupName:AdminGroupName
    AdminGroupObjectID:AdminGroupObjectID
    sqlIPWhiteLists:sqlIPWhiteLists
    location:location
    sqlPoolBackupType:sqlPoolBackupType
    sqlPooldwu:sqlPooldwu
  }
}
