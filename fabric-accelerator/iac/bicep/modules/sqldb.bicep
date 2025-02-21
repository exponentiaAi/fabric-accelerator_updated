@description('Name of SQL Server')
param sqlserver_name string = 'fabric-database'

@description('Name of Database')
param database_name string = 'Fabric'

@description('Azure Location SQL Server')
param location string = 'centralindia'

@description('Cost Centre tag that will be applied to all resources in this deployment')
param cost_centre_tag string = 'CostCentre'

@description('System Owner tag that will be applied to all resources in this deployment')
param owner_tag string = 'SystemOwner'

@description('Subject Matter Expert (SME) tag that will be applied to all resources in this deployment')
param sme_tag string = 'SME' 

@description('AD server admin user name')
@secure()
param ad_admin_username string = ['badal.salve@exponentia.ai', 'shreya.bhandge@exponentia.ai']

@description('SID (object ID) of the server administrator')
@secure()
param ad_admin_sid string = '8e0c3f69-ed67-4374-bad3-00925cc2a0ea'

@description('Database SKU name, e.g P3. For valid values, run this CLI az sql db list-editions -l australiaeast -o table')
param database_sku_name string ='GP_S_Gen5_1'

@description('Time in minutes after which database is automatically paused')
param auto_pause_duration int =60

//@description('Flag to indicate whether to enable integration of data platform resources with either an existing or new Purview resource')
//param enable_purview bool = true

@description('Flag to indicate whether to enable audit logging of SQL Server')
param enable_audit bool = false

//@description('Resource Name of new or existing Purview Account. Specify a resource name if create_purview=true or enable_purview=true')
//param purview_resource object = 'fabric-purviewAc'

@description('Resource name of audit storage account.')
param audit_storage_name string = 'fabricgen2datalake'

@description('Resource group of audit storage account is deployed')
param auditrg string = 'Fabric'

// Variables
var suffix = uniqueString(resourceGroup().id)
var sqlserver_unique_name = '${sqlserver_name}-${suffix}'

// Deploy SQL Server
resource sqlserver 'Microsoft.Sql/servers@2022-02-01-preview' ={
  name: sqlserver_unique_name
  location: location
  tags: {
    CostCentre: 'CostCentre123'
    SystemOwner: 'AdminTeam'
    SME: 'SME_Team'
    }
  identity:{ type: 'SystemAssigned'}
  properties: {
    administrators:{
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: true
      login: 'badal.salve@exponentia.ai'
      sid: '8e0c3f69-ed67-4374-bad3-00925cc2a0ea'
      principalType: 'Group'
      tenantId: 'fb33e7e1-6a98-4d5a-bd25-f47acf95078a'
    }
    minimalTlsVersion: '1.2'

  }
}

// Create firewall rule to Allow Azure services and resources to access this SQL Server
resource allowAzure_Firewall 'Microsoft.Sql/servers/firewallRules@2021-11-01' ={
  name: 'query-editor-931182'
  parent: sqlserver
  properties:{
    startIpAddress:'223.233.82.69'
    endIpAddress: '223.233.82.69'
  }
}
// Deploy database
resource database 'Microsoft.Sql/servers/databases@2022-11-01-preview' ={
  name: database_name
  location: location
  tags: {
    CostCentre: 'CostCentre123'
    SystemOwner: 'AdminTeam'
    SME: 'SME_Team'
    }
  sku:{name: 'GP_S_Gen5'}
  parent: sqlserver
  properties: {
    autoPauseDelay:60
  }
}

//Get Reference to audit storage account
resource audit_storage_account 'Microsoft.Storage/storageAccounts@22022-05-01' existing = if(enable_audit) {
  name: audit_storage_name
  scope: resourceGroup(auditrg)
}

module storage_permissions 'storage-permissions.bicep' = if(enable_audit)  {
  name: 'storage_permissions'
  scope: resourceGroup(auditrg)
  params:{
    storage_name: audit_storage_name
    storage_rg: auditrg
    principalId: '8e0c3f69-ed67-4374-bad3-00925cc2a0ea'
    grant_reader: false
    grant_contributor: true
  }
}

//
// Deploy audit diagnostics Azure SQL Server to storage account
resource sqlserver_audit 'Microsoft.Sql/servers/auditingSettings@2022-02-01-preview' = if(enable_audit)  {
  name: 'default'
  parent: sqlserver
  properties: {
    auditActionsAndGroups: ['BATCH_COMPLETED_GROUP','SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP','FAILED_DATABASE_AUTHENTICATION_GROUP']
    isAzureMonitorTargetEnabled: true
    isDevopsAuditEnabled: true
    isManagedIdentityInUse: true
    isStorageSecondaryKeyInUse: false
    retentionDays: 90
    state: 'Enabled'
    storageAccountSubscriptionId: '224a3c65-8eb9-4654-8ba7-ea005536e634'
    storageEndpoint: 'https://fabricgen2datalake.blob.core.windows.net/'
 }
}
//Role Assignment
@description('This is the built-in Storage Blob Reader role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#contributor')
resource readerRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: 'Azure subscription 1'
  name: '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
}

//resource grant_purview_reader_role 'Microsoft.Authorization/roleAssignments@2023-05-01-preview' = if (enable_purview){
  //name: guid(subscription().subscriptionId, sqlserver.name, readerRoleDefinition.id)
  //scope: sqlserver
  //properties: {
    //principalType: 'ServicePrincipal'
   //-- principalId: 'ea10fc09-baf2-495b-a56b-f9a139dd4c00'
   //-- roleDefinitionId: readerRoleDefinition.id
  //}
//}
output sqlserver_uniquename string = sqlserver.name
output database_name string = database.name
output sqlserver_resource object = sqlserver
output database_resource object = database
