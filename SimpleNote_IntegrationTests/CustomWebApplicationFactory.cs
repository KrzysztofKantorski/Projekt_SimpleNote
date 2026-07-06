using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Projekt_SimpleNote.Data;
using Testcontainers.PostgreSql;
using Microsoft.Extensions.DependencyInjection;

namespace SimpleNote_IntegrationTests
{
    public class CustomWebApplicationFactory : WebApplicationFactory<Program>, IAsyncLifetime
    {
        static CustomWebApplicationFactory()
        {
            //Load env variables
            DotNetEnv.Env.Load();
        }

        // Zmień inicjalizację _dbContainer, aby użyć nowego konstruktora z parametrem image
        private readonly PostgreSqlContainer _dbContainer = new PostgreSqlBuilder("postgres:15-alpine")
            .WithDatabase(Environment.GetEnvironmentVariable("TEST_DB_NAME") ?? "SimpleNoteTestDb")
            .WithUsername(Environment.GetEnvironmentVariable("TEST_DB_USER") ?? "postgres")
            .WithPassword(Environment.GetEnvironmentVariable("TEST_DB_PASSWORD") ?? "postgres")
            .Build();

        protected override void ConfigureWebHost(IWebHostBuilder builder)
        {
            builder.ConfigureServices(services =>
            {
                //Find and delete the existing ApplicationDbContext
                var descriptor = services.SingleOrDefault(
                    d => d.ServiceType == typeof(DbContextOptions<ApplicationDbContext>));

                if (descriptor != null)
                {
                    services.Remove(descriptor);
                }

                //Add new ApplicationDbContext
                services.AddDbContext<ApplicationDbContext>(options =>
                {
                    options.UseNpgsql(_dbContainer.GetConnectionString());
                });
            });
        }

        public async Task InitializeAsync()
        {
            //Run docker container
            await _dbContainer.StartAsync();

            //Apply migration
            using var scope = Services.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            await db.Database.MigrateAsync();
        }

        public new async Task DisposeAsync()
        {
            //Close and delete container
            await _dbContainer.StopAsync();
        }



    }
}
