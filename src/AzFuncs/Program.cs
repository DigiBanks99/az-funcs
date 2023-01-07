using AzFuncs.Commands.Handlers;
using MediatR;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var host = new HostBuilder()
    .ConfigureFunctionsWorkerDefaults()
    .ConfigureServices(services => services.AddMediatR(typeof(Program)).AddTransient<HelloCommandHandler>())
    .Build();

host.Run();
