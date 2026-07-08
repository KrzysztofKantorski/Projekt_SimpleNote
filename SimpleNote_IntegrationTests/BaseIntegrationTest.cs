using Microsoft.Extensions.DependencyInjection;
using Projekt_SimpleNote.Data;

namespace SimpleNote_IntegrationTests
{
    public abstract class BaseIntegrationTest : IClassFixture<CustomWebApplicationFactory>, IDisposable
    {
        protected readonly HttpClient Client;
        protected readonly ApplicationDbContext DbContext;
        private readonly IServiceScope _scope;

        protected BaseIntegrationTest(CustomWebApplicationFactory factory)
        {
            Client = factory.CreateClient();
            _scope = factory.Services.CreateScope();
            DbContext = _scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

            //Clear database before each test
            DbContext.Comments.RemoveRange(DbContext.Comments);
            DbContext.Notes.RemoveRange(DbContext.Notes);
            DbContext.Users.RemoveRange(DbContext.Users);
            DbContext.Subjects.RemoveRange(DbContext.Subjects);
            DbContext.Tags.RemoveRange(DbContext.Tags);
            DbContext.NoteReactions.RemoveRange(DbContext.NoteReactions);
            DbContext.ReactionTypes.RemoveRange(DbContext.ReactionTypes);
            DbContext.RefreshTokens.RemoveRange(DbContext.RefreshTokens);

            //Save changes
            DbContext.SaveChanges();
        }

        public void Dispose()
        {
            _scope.Dispose();
        }
    }
}
