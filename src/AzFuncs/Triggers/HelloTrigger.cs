using System.Net;
using AzFuncs.Commands.Messages;
using MediatR;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

namespace AzFuncs.Triggers;

public sealed class HelloTrigger
{
    private readonly IMediator _mediator;
    private readonly ILogger _logger;

    public HelloTrigger(ILoggerFactory loggerFactory, IMediator mediator)
    {
        _mediator = mediator;
        _logger = loggerFactory.CreateLogger<HelloTrigger>();
    }

    [Function(nameof(HelloTrigger))]
    public async Task<HttpResponseData> RunAsync([HttpTrigger(AuthorizationLevel.Function,
            "get",
            "post")]
        HttpRequestData req,
        FunctionContext context,
        CancellationToken cancellationToken)
    {
        _logger.LogInformation("C# HTTP trigger function processed a request");

        if (!context.BindingContext.BindingData.TryGetValue("name", out object? nameParam))
        {
            return req.CreateResponse(HttpStatusCode.BadRequest);
        }

        string name = $"{nameParam}";
        HttpResponseData response = req.CreateResponse(HttpStatusCode.OK);
        response.Headers.Add("Content-Type", "text/plain; charset=utf-8");

        HelloMessage helloMessage = new(name);
        string helloResponse = await _mediator.SendAsync(helloMessage, cancellationToken).ConfigureAwait(false);
        await response.WriteStringAsync(helloResponse).ConfigureAwait(false);

        return response;
    }
}
