@allowed([
  'West US'
])
param location string
param sbName string = 'sb-azurefuncs'

resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: sbName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    zoneRedundant: false
  }
}

resource authRuleRoot 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2022-01-01-preview' = {
  name: 'RootManageSharedAccessKey'
  parent: serviceBus
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}

resource authRuleSas 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2022-01-01-preview' = {
  name: 'REST'
  parent: serviceBus
  properties: {
    rights: ['Send']
  }
}

resource networkRules 'Microsoft.ServiceBus/namespaces/networkRuleSets@2022-01-01-preview' = {
  name: 'default'
  parent: serviceBus
  properties: {
    publicNetworkAccess: 'Enabled'
    defaultAction: 'Allow'
  }
}

resource queueDevQueue 'Microsoft.ServiceBus/namespaces/queues@2022-01-01-preview' = {
  name: 'devQueue'
  parent: serviceBus
  properties: {
    maxMessageSizeInKilobytes: 256
    lockDuration: 'PT30S'
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    requiresSession: false
    defaultMessageTimeToLive: 'P1D'
    deadLetteringOnMessageExpiration: false
    enableBatchedOperations: true
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    maxDeliveryCount: 10
    enablePartitioning: false
    enableExpress: false
  }
}

resource queueQueue 'Microsoft.ServiceBus/namespaces/queues@2022-01-01-preview' = {
  name: 'queue'
  parent: serviceBus
  properties: {
    maxMessageSizeInKilobytes: 256
    lockDuration: 'PT30S'
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    requiresSession: false
    defaultMessageTimeToLive: 'P1D'
    deadLetteringOnMessageExpiration: false
    enableBatchedOperations: true
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    maxDeliveryCount: 10
    enablePartitioning: false
    enableExpress: false
  }
}

resource queueOutputQueue 'Microsoft.ServiceBus/namespaces/queues@2022-01-01-preview' = {
  name: 'outputQueue'
  parent: serviceBus
  properties: {
    maxMessageSizeInKilobytes: 256
    lockDuration: 'PT30S'
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    requiresSession: false
    defaultMessageTimeToLive: 'P1D'
    deadLetteringOnMessageExpiration: false
    enableBatchedOperations: true
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    maxDeliveryCount: 10
    enablePartitioning: false
    enableExpress: false
  }
}
