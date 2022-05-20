targetScope = 'resourceGroup'


// param tags object 
param storageName string
param fileSystemNames array
param isNeedResourceAccessRules bool = false
param storageIPWhiteLists array 
param location string 
param isHnsEnabled bool 
param tags object

var storageNameCleaned = replace(storageName,'-','')
var resourceAccessRules = isNeedResourceAccessRules ?  [
  {
    tenantId: subscription().tenantId
    resourceId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/*/providers/Microsoft.Synapse/workspaces/*'
  }
] :[] 


resource storage 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageNameCleaned
  location: location
  tags:tags
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    encryption: {
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: false
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
        queue: {
          enabled: true
          keyType: 'Service'
        }
        table: {
          enabled: true
          keyType: 'Service'
        }
      }
    }
    isHnsEnabled: isHnsEnabled
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: storageIPWhiteLists
      virtualNetworkRules: []
      resourceAccessRules: resourceAccessRules
    }
    supportsHttpsTrafficOnly: true
  }
}

resource storageBlobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-02-01' = {
  parent: storage
  name: 'default'
  properties: {
  }
}

resource storageFileSystems 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01' = [for fileSystemName in fileSystemNames: {
  parent: storageBlobServices
  name: fileSystemName
  properties: {
    publicAccess: 'None'
    metadata: {}
  }
}]

// Outputs
output storageId string = storage.id
output storageFileSystemIds array = [for fileSystemName in fileSystemNames: {
  storageFileSystemId: resourceId('Microsoft.Storage/storageAccounts/blobServices/containers', storageNameCleaned, 'default', fileSystemName)
}]
