using AzFuncs;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var host = new HostBuilder()
    .ConfigureFunctionsWorkerDefaults()
    .ConfigureAppConfiguration(context => context.AddJsonFile("appsettings.json", true, true))
    .ConfigureServices(services => services.AddTransient<HelloCommandHandler>())
    .Build();

host.Run();
