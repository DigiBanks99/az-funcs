using AzFuncs.Commands.Messages;
using MediatR;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace AzFuncs.Triggers;

public class ServiceBusTriggerFunc
{
    private readonly IMediator _mediator;

    public ServiceBusTriggerFunc(IMediator mediator)
    {
        _mediator = mediator;
    }

    [Function(nameof(ServiceBusTrigger))]
    [ServiceBusOutput("outputQueue", Connection = "ServiceBusConnection")]
    public async Task<string> ServiceBusTrigger([ServiceBusTrigger("%ServiceBusInboundQueue%", Connection = "ServiceBusConnection")] string item,
        FunctionContext context)
    {
        var logger = context.GetLogger("ServiceBusFunction");

        logger.LogInformation("Reading queue message: {Item}", item);

        HelloMessage helloMessage = new(item);

        string response = await _mediator.SendAsync(helloMessage, CancellationToken.None).ConfigureAwait(false);

        return response;
    }
}