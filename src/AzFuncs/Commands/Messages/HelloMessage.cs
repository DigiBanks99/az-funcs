using MediatR;

namespace AzFuncs.Commands.Messages;

public class HelloMessage : IRequest<string>
{
    public HelloMessage(string name)
    {
        Name = name;
    }
    public string Name { get; }
}