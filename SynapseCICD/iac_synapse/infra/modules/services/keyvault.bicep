// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// This template is used to create a KeyVault.
targetScope = 'resourceGroup'

// Parameters
param location string
param keyvaultName string
param ipRules array
param tags object

// Variables


// Resources
resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' = {
  name: keyvaultName
  location: location
  tags: tags
  properties:{
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableRbacAuthorization: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: ipRules
      virtualNetworkRules: []
    }
    // enableSoftDelete: true
    // softDeleteRetentionInDays:10
    tenantId: subscription().tenantId
  }
}


// Outputs
output keyvaultId string = keyVault.id
output keyVaultName string = keyVault.name
