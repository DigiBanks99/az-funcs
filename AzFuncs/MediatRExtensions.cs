using MediatR;

namespace AzFuncs;

internal static class MediatRExtensions
{
    internal static Task<TResponse> SendAsync<TResponse>(this IMediator mediator, IRequest<TResponse> message, CancellationToken cancellationToken)
    {
        return mediator.Send(message, cancellationToken);
    }
}