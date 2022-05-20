// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// The module contains a template to create a role assignment to a storage account file system.
targetScope = 'resourceGroup'

// Parameters
param storageAccountId string
param synapseId string
param groupObjectId string 
param keyvaultId string

// Variables
var storageAccountName = last(split(storageAccountId,'/'))
var synapseName = last(split(synapseId,'/'))
var keyVaultame = last(split(keyvaultId,'/'))


// Resources
// 新規作成物
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' existing = {
  name: '${storageAccountName}'
}

resource synapse 'Microsoft.Synapse/workspaces@2021-06-01' existing = {
  name: synapseName
}


resource keyvault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  name: keyVaultame
}



// 以下、RBAC設定
// サービス間認証

// 新規内
// Synapse->Data Lake Storage *ストレージ Blobデータ共同作成者*
resource SynapseStorageRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(storageAccount.id, synapse.id,'blobcontributor')
  scope: storageAccount
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')//blobcontributor
    principalId: synapse.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource SynapseKeyVaultRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(keyvault.id, synapse.id,'secretuser')
  scope: keyvault
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')//secretuser
    principalId: synapse.identity.principalId
    principalType: 'ServicePrincipal'
  }
}


// 開発ユーザー->リソースグループ 
resource groupKeyvaultRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' =if (!empty(groupObjectId)){
  name: guid(resourceGroup().id, groupObjectId,'blobcontributor')
  scope: resourceGroup()
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')//keyvaultadmin
    principalId: groupObjectId
    principalType: 'Group'
  }
}

// Outputs
