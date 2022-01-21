// The module contains a template to create a role assignment of the Synase MSI to a file system.
targetScope = 'resourceGroup'

// Parameters
param storageAccountFileSystemId string
param synapseId string

// Variables
var storageAccountName = length(split(storageAccountFileSystemId, '/')) >= 13 ? split(storageAccountFileSystemId, '/')[8] : 'incorrectSegmentLength'
var synapseSubscriptionId = length(split(synapseId, '/')) >= 9 ? split(synapseId, '/')[2] : subscription().subscriptionId
var synapseResourceGroupName = length(split(synapseId, '/')) >= 9 ? split(synapseId, '/')[4] : resourceGroup().name
var synapseName = length(split(synapseId, '/')) >= 9 ? last(split(synapseId, '/')) : 'incorrectSegmentLength'

// Resources
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' existing = {
  name: '${storageAccountName}'
}

resource synapse 'Microsoft.Synapse/workspaces@2021-03-01' existing = {
  name: synapseName
  scope: resourceGroup(synapseSubscriptionId, synapseResourceGroupName)
}

resource synapseRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(storageAccount.id, synapse.id, 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
  scope: storageAccount
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
    principalId: synapse.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Outputs