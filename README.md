# Azure Functions with Azure Service Bus

This repo is a small little sandbox to test out how Azure Functions v4 work with Azure Service Bus. The functions are implemented using C# in the Isolated context.

## Getting started

Clone the repo:

```sh
git clone git@github.com:DigiBanks99/az-funcs.git
```

Next create an Azure environment using [learn.microsoft.com](https://learn.microsoft.com).

Once you've got a Concierge Subscription going, deploy the infrastructure as follows:

1. Open VS Code or a tool that can use Bicep
2. Ensure the [Bicep Extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep) is installed
3. Deploy the [Service Bus template](templates/service-bus.bicep)
4. Next deploy the [Functions template](templates/functions.bicep)
5. Once deployment is complete you can deploy the AzFuncs project using Visual Studio, Rider or VS Code

You can test the HTTP trigger by going to <https://yourfuncname.azurewebsites.net/api/HttpTrigger?name=somename&code=theauthcodeobtainablefromazureportal>

You can test the service bus trigger by running the MessageQueuer project and posting JSON objects to the `message` endpoint
