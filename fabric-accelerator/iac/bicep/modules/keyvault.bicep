
// Parameters
@description('Location where resources will be deployed. Defaults to resource group location')
param location string = 'centralindia'

@description('Cost Centre tag that will be applied to all resources in this deployment')
param cost_centre_tag string = 'CostCentre'

@description('System Owner tag that will be applied to all resources in this deployment')
param owner_tag string = 'SystemOwner'

@description('Subject Matter Expert (SME) tag that will be applied to all resources in this deployment')
param sme_tag string = 'SME'

@description('Key Vault name')
param keyvault_name string = 'fabric-keyuser'

// Variables
var suffix = uniqueString(resourceGroup().id)
var keyvault_uniquename = '${keyvault_name}-${suffix}'


// Create Key Vault
resource keyvault 'Microsoft.KeyVault/vaults@2016-10-01' ={
  name: keyvault_name
  location: location
  tags: {
    CostCentre: 'CostCentre123'
    SystemOwner: 'AdminTeam'
    SME: 'SME_Team'
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


output keyvault_name string = keyvault.name
