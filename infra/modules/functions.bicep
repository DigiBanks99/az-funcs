@description('The Azure region into which the Service Bus is to be deployed')
param location string

@description('The name of the Azure Function')
param functionName string

@description('The name of the App Service Plan that will host the Azure Function')
param planName string

@description('The name of the Storage Account backing the Azure Function')
param storageAccountName string

@description('The Fully Qualified name of the Azure Service Bus Namespace')
param serviceBusFqName string

var storageAccountRoleIds = [
  'b7e6dc6d-f1e8-4753-8033-0f276bb0955b' // Storage Blob Data Owner
  '17d1049b-9a84-46fb-8f53-869881c3d3ab' // Storage Account Contributor
  '974c5e8b-45b9-4653-ba55-5f855dd0fb88' // Storage Queue Data Contributor
]

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

resource fileStorage 'Microsoft.Storage/storageAccounts/fileServices@2022-05-01' = {
  name: 'default'
  parent: storageAccount
  properties: {
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

resource queueStorage 'Microsoft.Storage/storageAccounts/queueServices@2022-05-01' = {
  name: 'default'
  parent: storageAccount
}

resource tableStorage 'Microsoft.Storage/storageAccounts/tableServices@2022-05-01' = {
  name: 'default'
  parent: storageAccount
}

resource blobStorage 'Microsoft.Storage/storageAccounts/blobServices@2022-05-01' = {
  name: 'default'
  parent: storageAccount
  properties: {
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: false
    }
  }
}

resource blobContainerWebJobHosts 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  name: 'azure-webjobs-hosts'
  parent: blobStorage
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
}

resource blobContainerWebJobSecrets 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  name: 'azure-webjobs-secrets'
  parent: blobStorage
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
}

resource blobContainerScmReleases 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  name: 'scm-releases'
  parent: blobStorage
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
}

resource servicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: planName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
  }
  kind: 'functionapp'
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: true
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
}

resource function 'Microsoft.Web/sites@2022-03-01' = {
  name: functionName
  location: location
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${functionName}.azurewebsite.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${functionName}.scm.azurewebsite.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: servicePlan.id
    vnetRouteAllEnabled: false
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
    siteConfig: {
      numberOfWorkers: 1
      linuxFxVersion: 'DOTNET-ISOLATED|6.0'
      acrUseManagedIdentityCreds: false
      alwaysOn: false
      http20Enabled: false
      functionAppScaleLimit: 200
      minimumElasticInstanceCount: 0
    }
    clientAffinityEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    httpsOnly: true
    storageAccountRequired: false
  }
}

resource funcsConfig 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'web'
  parent: function
  properties: {
    numberOfWorkers: 1
    netFrameworkVersion: 'v4.0'
    linuxFxVersion: 'DOTNET-ISOLATED|6.0'
    appSettings: [
      {
        name: 'AzureWebJobsStorage__accountName'
        value: storageAccountName
      }
      {
        name: 'AzureWebJobsStorage__blobServiceUri'
        value: 'https://${storageAccountName}.${storageAccount.properties.primaryEndpoints.blob}'
      }
      {
        name: 'AzureWebJobsStorage__queueServiceUri'
        value: 'https://${storageAccountName}.${storageAccount.properties.primaryEndpoints.queue}'
      }
      {
        name: 'AzureWebJobsStorage__tableServiceUri'
        value: 'https://${storageAccountName}.${storageAccount.properties.primaryEndpoints.table}'
      }
      {
        name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
        value: 'false'
      }
      {
        name: 'ServiceBusConnection__fullyQualifiedName'
        value: serviceBusFqName
      }
      {
        name: 'ServiceBusInboundQueue'
        value: 'queue'
      }
      {
        name: 'FUNCTIONS_EXTENSION_VERSION'
        value: '~4'
      }
      {
        name: 'FUNCTIONS_WORKER_RUNTIME'
        value: 'dotnet-isolated'
      }
      {
        name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
        value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
      }
      {
        name: 'WEBSITE_CONTENTSHARE'
        value: toLower(functionName)
      }
      {
        name: 'WEBSITE_RUN_FROM_PACKAGE'
        value: '1'
      }
    ]
  }
}

resource storageAccountRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleId in storageAccountRoleIds: {
  name: guid('role-${storageAccountName}-${roleId}')
  scope: storageAccount
  properties: {
    principalId: function.identity.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleId)
  }
}]
