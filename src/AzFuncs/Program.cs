using System.Reflection;
using AzFuncs.Commands.Handlers;
using MediatR;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var host = new HostBuilder()
    .ConfigureFunctionsWorkerDefaults(builder =>
    {
        builder.Services.AddMediatR(typeof(Program)).AddTransient<HelloCommandHandler>();
    })
    .ConfigureAppConfiguration(builder =>
    {
        builder.AddUserSecrets(Assembly.GetEntryAssembly());
    })
    .Build();

host.Run();
