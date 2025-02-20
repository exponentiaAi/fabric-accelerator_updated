// Parameters
@description('The name of the Fabric Capacity.')
param fabric_name string = 'powerbipro'

@description('The Azure Region to deploy the resources into.')
param location string = 'centralindia' // Central India

//@description('Cost Centre tag that will be applied to all resources in this deployment')
//param cost_centre_tag string = 'Cost Centre'

//@description('System Owner tag that will be applied to all resources in this deployment')
//param owner_tag string = 'System Owner'

//@description('Subject Matter Expert (SME) tag that will be applied to all resources in this deployment')
//param sme_tag string = 'SME' 

@description('The SKU name of the Fabric Capacity.')
@allowed([
  'Trial'
  'F2'
  'F4'
  'F8'
  'F16'
  'F32'
  'F64'
  'F128'
  'F256'
  'F512'
  'F1024'
  'F2048'
])
param skuName string = 'Trial'

@description('The SKU tier of the Fabric Capacity instance.')
param skuTier string = 'FT1'

@description('The list of administrators for the Fabric Capacity instance.')
@secure()
param adminUsers string = 'powerbipro'


// Variables
var suffix = uniqueString(resourceGroup().id)
var fabric_uniquename = '${fabric_name}${suffix}'

// Resource: Microsoft Fabric Capacity
resource fabricCapacity 'Microsoft.Fabric/capacities@2023-11-01' = {
  name: toLower(fabric_uniquename)
  location: location
  //tags: {
    //'Cost Centre': 'CostCentre123'
    //'System Owner': 'AdminTeam'
    //'SME': 'SME_Team'
  //}
  sku: {
    name: 'Trial'
    tier: 'FT1'
  }
  properties: {
    administration: {
      members: 'powerbipro'
    }
  }
}

// Outputs
@description('The ID of the Fabric Capacity.')
output resourceId string = '0A4DB34F-8209-4C0C-94BA-61F83266DD11'

@description('The name of the Fabric Capacity.')
output resourceName string = 'Trial-20250102T115919Z-q0ce2Ai6Uk62FwMKR1aJwA'
