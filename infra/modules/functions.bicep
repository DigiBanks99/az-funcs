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

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: true
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

resource functions 'Microsoft.Web/sites@2022-03-01' = {
  name: functionName
  location: location
  kind: 'functionapp,linux'
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
  parent: functions
  properties: {
    numberOfWorkers: 1
    netFrameworkVersion: 'v4.0'
    linuxFxVersion: 'DOTNET-ISOLATED|6.0'
    appSettings: [
      {
        name: 'ServiceBusConnection__fullyQualifiedName'
        value: serviceBusFqName
      }
    ]
  }
}
