using System.Net;
using System.Runtime.CompilerServices;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace AzFuncs;

public class AzHttp
{
    private readonly IConfiguration _config;
    private readonly HelloCommandHandler _handler;
    private readonly ILogger _logger;

    public AzHttp(ILoggerFactory loggerFactory, IConfiguration config, HelloCommandHandler handler)
    {
        _config = config;
        _handler = handler;
        _logger = loggerFactory.CreateLogger<AzHttp>();
    }

    [Function(nameof(HelloTrigger))]
    public async Task<HttpResponseData> HelloTrigger([HttpTrigger(AuthorizationLevel.Function,
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

        string message = await _handler.HandleAsync(name, cancellationToken).ConfigureAwait(false);
        await response.WriteStringAsync(message).ConfigureAwait(false);

        return response;
    }
}