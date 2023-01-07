using AzFuncs.Commands.Messages;
using MediatR;
using Microsoft.Extensions.Logging;

namespace AzFuncs.Commands.Handlers;

public class HelloCommandHandler : IRequestHandler<HelloMessage, string>
{
    private readonly ILogger<HelloCommandHandler> _logger;

    public HelloCommandHandler(ILogger<HelloCommandHandler> logger)
    {
        _logger = logger;
    }

    public Task<string> Handle(HelloMessage message, CancellationToken cancellationToken)
    {
        return Task.Run(() =>
        {
            _logger.LogInformation("Hello {Name}!", message.Name);
            return $"Hello {message.Name}!";
        }, cancellationToken);
    }
}