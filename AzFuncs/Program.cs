using AzFuncs;
using MediatR;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var host = new HostBuilder()
    .ConfigureFunctionsWorkerDefaults()
    .ConfigureAppConfiguration(context => context.AddJsonFile("appsettings.json", true, true))
    .ConfigureServices(services => services.AddMediatR(typeof(Program)).AddTransient<HelloCommandHandler>())
    .Build();

host.Run();
