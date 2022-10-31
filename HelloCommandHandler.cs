using MediatR;
using Microsoft.Extensions.Logging;

namespace AzFuncs;

public class HelloMessage : IRequest<string>
{
    public HelloMessage(string name)
    {
        Name = name;
    }
    public string Name { get; }
}

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