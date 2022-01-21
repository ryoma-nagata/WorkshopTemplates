targetScope = 'resourceGroup'

@description('自分のリソースを識別するためにリソース名の先頭に付与する文字を入力してください。（最大4文字）例：永田→ngt')
@maxLength(4)
param prefix string 

// @description('デプロイ先のリージョン。変更不要')
// param location string ='japaneast'

@description('Azure Sql管理者名')
param sqlLogin string = 'sqladmin' 
@secure()
@description('Azure Sql管理者パスワード')
param sqlPassword string

@description('作成日')
param createDate string =  dateTimeAdd(utcNow('u'), 'PT9H','yyyy/MM/dd')
var uniqueId = uniqueString(resourceGroup().id)
var synapseName = '${prefix}-syn-${uniqueId}'
var sqlserverName = '${prefix}-sql-${uniqueId}'
var storageName = replace(replace(toLower('${prefix}-dls-${uniqueId}'), '-', ''), '_', '')
var FileSytemNames = [
  'data'
]

var tags ={
  Environment:'ZEAL-Hands-On'
  CreateDate: createDate
  Prefix : prefix
}

module synapse 'modules/services/synapse.bicep' = {
  name:'synapseDeploy'
  params:{
    tags: tags
    synapseDefaultStorageAccountFileSystemId: storage.outputs.storageFileSystemIds[0].storageFileSystemId
    synapseName: synapseName
    administratorUsername:sqlLogin
    administratorPassword:sqlPassword

  }
}

module storage 'modules/services/storage.bicep' = {
  name:'storageDeploy'
  params:{
    tags:tags
    fileSystemNames:FileSytemNames
    storageName:storageName
  }
}

module sql 'modules/services/sql.bicep' = {
  name:'sqlDeploy'
  params:{
    sqlLogin: sqlLogin
    sqlserverName:sqlserverName 
    sqlPassword: sqlPassword
    tags:tags
  }
}

module synapseToStorageRBAC 'modules/auxiliary/roleAssingment.bicep' ={
  name:'synapseToStorageRBAC'
  params:{
    storageAccountFileSystemId: storage.outputs.storageFileSystemIds[0].storageFileSystemId
    synapseId: synapse.outputs.synapseId
  }
}
