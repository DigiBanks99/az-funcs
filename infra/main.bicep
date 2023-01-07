@allowed([
  'West US'
  'centralus'
  'southafricanorth'
])
@description('The Azure region into which the Service Bus is to be deployed')
param location string

@description('The name of the Service Bus to be deployed')
param sbName string

@description('The name of the Azure Function')
param functionName string

@description('The name of the App Service Plan that will host the Azure Function')
param planName string

@description('The name of the Storage Account backing the Azure Function')
param storageAccountName string

module serviceBus 'modules/service-bus.bicep' = {
  name: sbName
  params: {
    location: location
    sbName: sbName
  }
}

module function 'modules/functions.bicep' = {
  name: functionName
  params: {
    location: location
    functionName: functionName
    planName: planName
    storageAccountName: storageAccountName
    serviceBusFqName: serviceBus.outputs.serviceBusFullyQualifiedName
  }
}

@description('The fully qualified name of the Service Bus Namespace')
output serviceBusFullyQualifiedName string = serviceBus.outputs.serviceBusFullyQualifiedName
