using Azure.Messaging.ServiceBus;
using Microsoft.AspNetCore.Mvc;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.MapPost("/message", async ([FromBody] string body, IConfiguration config) =>
{
    ServiceBusClient client = new(config.GetValue<string>("ServiceBusConnection"));
    ServiceBusSender sender = client.CreateSender(config.GetValue<string>("ServiceBusInboundQueue"));

    try
    {
        await sender.SendMessageAsync(new(body)).ConfigureAwait(false);
    }
    finally
    {
        await sender.DisposeAsync();
        await client.DisposeAsync();
    }
});

app.Run();