using Microsoft.Extensions.Logging;

namespace AzFuncs;

public class HelloCommandHandler
{
    private readonly ILogger<HelloCommandHandler> _logger;

    public HelloCommandHandler(ILogger<HelloCommandHandler> logger)
    {
        _logger = logger;
    }

    public Task<string> HandleAsync(string name, CancellationToken cancellationToken)
    {
        return Task.Run(() =>
        {
            _logger.LogInformation("Hello {Name}!", name);
            return $"Hello {name}!";
        }, cancellationToken);
    }
}