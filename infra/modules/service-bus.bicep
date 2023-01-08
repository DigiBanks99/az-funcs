@description('The Azure region into which the Service Bus is to be deployed')
param location string

@description('The name of the Service Bus to be deployed')
param sbName string

resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: sbName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: true
    zoneRedundant: false
  }
}

resource queueDevQueue 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = {
  name: 'devQueue'
  parent: serviceBus
}

resource queueQueue 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = {
  name: 'queue'
  parent: serviceBus
}

resource queueOutputQueue 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = {
  name: 'outputQueue'
  parent: serviceBus
}

@description('The fully qualified name of the Service Bus Namespace')
output serviceBusFullyQualifiedName string = '${sbName}.servicebus.windows.net'
