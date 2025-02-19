
// Parameters
@description('Location where resources will be deployed. Defaults to resource group location')
param location string = 'centralindia'

@description('Cost Centre tag that will be applied to all resources in this deployment')
param cost_centre_tag string = 'Cost Centre'

@description('System Owner tag that will be applied to all resources in this deployment')
param owner_tag string = 'System Owner'

@description('Subject Matter Expert (SME) tag that will be applied to all resources in this deployment')
param sme_tag string = 'SME'

@description('Key Vault name')
param keyvault_name string = 'fabric-keyuser'

@description('Purview Account name')
param purview_account_name string = 'fabric-purviewAc'

@description('Resource group of Purview Account')
param purviewrg string = 'Fabric'

@description('Flag to indicate whether to enable integration of data platform resources with either an existing or new Purview resource')
param enable_purview bool=true

// Variables
var suffix = uniqueString(resourceGroup().id)
var keyvault_uniquename = '${keyvault_name}-${suffix}'


// Create Key Vault
resource keyvault 'Microsoft.KeyVault/vaults@2016-10-01' ={
  name: keyvault_name
  location: location
  tags: {
    'Cost Centre': 'CostCentre123'
    'System Owner': 'AdminTeam'
    'SME': 'SME_Team'
  }
  properties:{
    tenantId: 'fb33e7e1-6a98-4d5a-bd25-f47acf95078a'
    sku: {
      family: 'A'
      name: 'standard'
    }
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    // Default Access Policies. Replace the ObjectID's with your user/group id
    accessPolicies:[
      { tenantId: 'fb33e7e1-6a98-4d5a-bd25-f47acf95078a'
        objectId: '8e0c3f69-ed67-4374-bad3-00925cc2a0ea' // Replace this with your user/group ObjectID
        permissions: {secrets:['list','get','set','Delete','Recover','Backup','Restore']}        
      }
      { tenantId: 'fb33e7e1-6a98-4d5a-bd25-f47acf95078a'
        objectId: '5d2bf1c7-0d3e-41dd-b2d3-b28745352812' // Replace this with your user/group ObjectID
        permissions: {secrets:['list','get','set','Delete','Recover','Backup','Restore']}
      }
      { tenantId: 'fb33e7e1-6a98-4d5a-bd25-f47acf95078a'
        objectId: '8b19b109-d314-4133-a05f-c249563a42cc' // Replace this with your user/group ObjectID
        permissions: {secrets:['list','get','set','Delete','Recover','Backup','Restore']}
      }
    ]
  }
}

// Create Key Vault Access Policies for Purview
resource existing_purview_account 'Microsoft.Purview/accounts@2023-05-01-preview' existing = if(enable_purview) {
    name: fabric-purviewAc
    scope: 'Fabric'
  }
  
resource this_keyvault_accesspolicy 'Microsoft.KeyVault/vaults/accessPolicies@2016-10-01' = if(enable_purview) {
  name: keyvault_name
  parent: '224a3c65-8eb9-4654-8ba7-ea005536e634'
  properties: {
    accessPolicies: [
      { tenantId: 'fb33e7e1-6a98-4d5a-bd25-f47acf95078a'
        objectId: 'ea10fc09-baf2-495b-a56b-f9a139dd4c00'
        permissions: {secrets:['list','get','set','Delete','Recover','Backup','Restore']}

      }
    ]
  }
}

output keyvault_name string = keyvault.name
