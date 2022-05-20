targetScope = 'resourceGroup'

param synapseName string
param synapseDefaultStorageAccountFileSystemId string 
param administratorUsername string = 'sqladmin'
@secure()
param administratorPassword string = ''
param purviewId string =''
param synapseSqlAdminGroupName string = ''
param synapseSqlAdminGroupObjectID string = ''
param AllowAzure bool = true
param sparkPoolName string
param sqlPoolName string
param collation string = 'Japanese_XJIS_100_CI_AS'
param location string 
@allowed([
  'LRS'
  'GRS'
])
param sqlPoolBackupType string
param sqlPooldwu string
param tags object

var sqlPoolNameCleaned = replace(sqlPoolName,'-','_')
var sparkPoolNameCleaned = replace(sparkPoolName,'-','_')
var synapseDefaultStorageAccountFileSystemName = length(split(synapseDefaultStorageAccountFileSystemId, '/')) >= 13 ? last(split(synapseDefaultStorageAccountFileSystemId, '/')) : 'incorrectSegmentLength'
var synapseDefaultStorageAccountName = length(split(synapseDefaultStorageAccountFileSystemId, '/')) >= 13 ? split(synapseDefaultStorageAccountFileSystemId, '/')[8] : 'incorrectSegmentLength'
var sparkdef = {
  autoPause: {
    enabled: true
    delayInMinutes: 15
  }
  autoScale: {
    enabled: true
    minNodeCount: 3
    maxNodeCount: 12
  }
  // libraryRequirements:{
  //   content:'pyapacheatlas'
  //   filename:'requirements.txt'
  // }
  customLibraries: []
  nodeSize: 'Small'
  nodeSizeFamily: 'MemoryOptimized'
  sessionLevelPackagesEnabled: true
  sparkVersion: '3.1'
}

param ipWhiteLists array = [
  {
    name:'AllowAllWindowsAzureIps'
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
]

resource synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name:synapseName
  location:location
  identity:{
    type:'SystemAssigned'
  }
  tags:tags
  properties:{
    defaultDataLakeStorage:{
      filesystem:synapseDefaultStorageAccountFileSystemName
      accountUrl: 'https://${synapseDefaultStorageAccountName}.dfs.${environment().suffixes.storage}'
    }
    sqlAdministratorLogin: administratorUsername
    sqlAdministratorLoginPassword: administratorPassword
    publicNetworkAccess: 'Enabled'
    purviewConfiguration:{
      purviewResourceId:purviewId
    }
    managedVirtualNetwork:'default'
    
  }
}


resource synapseBigDataPool001 'Microsoft.Synapse/workspaces/bigDataPools@2021-06-01' = {  
  parent: synapseWorkspace
  name: sparkPoolNameCleaned
  location: location
  properties: sparkdef
  tags:tags

}


resource networkACL 'Microsoft.Synapse/workspaces/firewallRules@2021-06-01'= [for ipWhiteList in ipWhiteLists: {
  name:ipWhiteList.name
  parent:synapseWorkspace
  properties:{
    startIpAddress: ipWhiteList.startIpAddress
    endIpAddress: ipWhiteList.endIpAddress
  }
}]

resource sqlpool 'Microsoft.Synapse/workspaces/sqlPools@2021-06-01'= if (!empty(sqlPoolName)) {
  parent: synapseWorkspace
  name: sqlPoolNameCleaned
  location:location
  tags:tags
  sku:{
    name: sqlPooldwu
  }
  properties:{
    collation:collation
    storageAccountType:sqlPoolBackupType
    
  }
}

resource tde 'Microsoft.Synapse/workspaces/sqlPools/transparentDataEncryption@2021-06-01' = {
  name: 'current'
  parent:sqlpool
  properties:{
    status:'Enabled'
  } 
}


resource synapseAadAdministrators 'Microsoft.Synapse/workspaces/administrators@2021-03-01' = if (!empty(synapseSqlAdminGroupName) && !empty(synapseSqlAdminGroupObjectID)) {
  parent: synapseWorkspace
  name: 'activeDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: synapseSqlAdminGroupName
    sid: synapseSqlAdminGroupObjectID
    tenantId: subscription().tenantId
  }
}

resource network 'Microsoft.Synapse/workspaces/firewallRules@2021-06-01' = if (AllowAzure)  {
  name:'AllowAllWindowsAzureIps'
  parent:synapseWorkspace
  properties:{
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}



output synapseId string = synapseWorkspace.id
output bigdatapoolName string = synapseBigDataPool001.name
output sparkDef object = sparkdef
