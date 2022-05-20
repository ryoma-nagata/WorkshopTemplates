
targetScope = 'resourceGroup'

// general params
@description('リソースのデプロイリージョン')
param location string = 'japaneast'

@description('リソース名はproject-deployment_id-リソース種類-envとなります')
param project string 
@allowed([
  'demo'
  'poc'
  'dev'
  'test'
  'prod'
  'stg'
])
@description('リソース名はproject-deployment_id-リソース種類-envとなります')
param env string 
@description('リソース名はproject-deployment_id-リソース種類-envとなります')
param deployment_id string = '01'
@description('許可したいIPリスト')
param storageIPWhiteLists array =[
  {
  value: '*.*.*.*'
  action: 'Allow'
  }
]
@description('許可したいIPリスト')
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
param AdminGroupObjectID string = ''
@allowed([
  'LRS'
  'GRS'
])
@description('SQLPoolのバックアップタイプ')
param sqlPoolBackupType string = 'LRS'
@description('SQLPoolの性能SKU')
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
