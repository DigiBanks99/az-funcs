using System.Collections.Generic;
using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace AzFuncs;

public class AzHttp
{
    private readonly IConfiguration _config;
    private readonly ILogger _logger;

    public AzHttp(ILoggerFactory loggerFactory, IConfiguration config)
    {
        _config = config;
        _logger = loggerFactory.CreateLogger<AzHttp>();
    }

    [Function("HelloTrigger")]
    public HttpResponseData Run([HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequestData req)
    {
        _logger.LogInformation("C# HTTP trigger function processed a request");
        _logger.LogInformation("Reading config pipeline for 'foo': '{Foo}'", _config.GetValue<string>("Foo"));

        var response = req.CreateResponse(HttpStatusCode.OK);
        response.Headers.Add("Content-Type", "text/plain; charset=utf-8");

        response.WriteString("Welcome to Azure Functions!");

        return response;
    }
}