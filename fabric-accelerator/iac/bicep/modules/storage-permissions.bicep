@description('Resource name storage account to which permissions are to be granted')
param storage_name string = 'fabricgen2datalake'

@description('Resource group of storage account')
param storage_rg string = 'Fabric'

@description('Managed Identity of the resource being granted permissions')
param principalId string = ''

@description('Flag to grant Storage Blob Data Reader role to the storage account')
param grant_reader bool = true

@description('Flag to grant Storage Blob Data Contributor role to the storage account')
param grant_contributor bool = true

//Get Reference to storage account
resource storage_account 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: storage_name
  scope: resourceGroup(storage_rg)
}

//In-built role definition for storage account
@description('This is the built-in Storage Blob Contributor role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
resource sbdcRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: '224a3c65-8eb9-4654-8ba7-ea005536e634'
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
}

@description('This is the built-in Storage Blob Reader role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#contributor')
resource sbdrRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: '224a3c65-8eb9-4654-8ba7-ea005536e634'
  name: '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
}

//Grant Storage Blob Data Contributor role to resource
resource grant_sbdc_role 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if (grant_contributor) {
  name: guid(subscription().subscriptionId, principalId, sbdcRoleDefinition.id)
  // scope: fabricgen2datalake //needs to be uncommented when this is supported
  properties: {
    principalType: 'ServicePrincipal'
    principalId: '8e0c3f69-ed67-4374-bad3-00925cc2a0ea' // objectID
    roleDefinitionId: sbdcRoleDefinition.id
  }
}

//Grant Storage Blob Data Reader role to resource
resource grant_sbdr_role 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if (grant_reader) {
  name: guid(subscription().subscriptionId, principalId, sbdrRoleDefinition.id)
  // scope: fabricgen2datalake //needs to be uncommented when this is supported
  properties: {
    principalType: 'ServicePrincipal'
    principalId: '8b19b109-d314-4133-a05f-c249563a42cc' // ObjectID
    roleDefinitionId: sbdrRoleDefinition.id
  }
}
