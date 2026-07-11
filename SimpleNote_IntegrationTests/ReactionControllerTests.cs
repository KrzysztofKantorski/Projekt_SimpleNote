using Microsoft.EntityFrameworkCore;
using Projekt_SimpleNote.Dto.Reactions;
using Projekt_SimpleNote.Entities;
using SimpleNote_IntegrationTests.Helpers;
using System.Net;
using System.Net.Http.Json;

namespace SimpleNote_IntegrationTests
{
    public class ReactionControllerTests: BaseIntegrationTest
    {
        public ReactionControllerTests(CustomWebApplicationFactory factory) : base(factory)
        {
        }

        [Fact]
        public async Task GetAvaliableReactions_ShouldReturnOkAndReactions() 
        {
            var user = DbContext.CreateTestUser();
            DbContext.CreateTestReactionType(name: "Like", iconUrl: "url");
            DbContext.CreateTestReactionType(name: "Heart", iconUrl: "url");
            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(user);
            var url = "/api/reaction-types";

            var response = await Client.GetAsync(url);

            Assert.Equal(HttpStatusCode.OK, response.StatusCode);
            var result = await response.Content.ReadFromJsonAsync<List<AvailableReactionDto>>();
            Assert.NotNull(result);
            Assert.Equal(2, result.Count);
        }



        [Fact]
        public async Task GetNoteReactions_ShouldReturnOkAndSummary()
        {

            var noteOwner = DbContext.CreateTestUser(username: "Owner");
            var reactingUser = DbContext.CreateTestUser(username: "Reactor");

            var note = DbContext.CreateTestNote(user: noteOwner, subject: null);

            var testReactionType = DbContext.CreateTestReactionType(name: "Test", iconUrl: "url");

            DbContext.CreateTestNoteReaction(user: reactingUser, note: note, reactionType: testReactionType);

            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(reactingUser);
            var url = $"/api/notes/{note.Id}/reactions";

            var response = await Client.GetAsync(url);

            Assert.Equal(HttpStatusCode.OK, response.StatusCode);
            var result = await response.Content.ReadFromJsonAsync<List<NoteReactionSummaryDto>>();

            Assert.NotNull(result);
            Assert.Single(result); 
            Assert.Equal(1, result[0].Count); 

            //User reaction was noticed
            Assert.True(result[0].ReactedByCurrentUser);
        }


        [Fact]
        public async Task AddNoteReaction_ShouldReturnNoContent_AndSaveToDb()
        {
            var noteOwner = DbContext.CreateTestUser("Owner");
            var reactingUser = DbContext.CreateTestUser("Reactor");
            var note = DbContext.CreateTestNote(user: noteOwner, isPublic: true, subject: null);

            var reactionType = DbContext.CreateTestReactionType(name: "Like", iconUrl: "url");
            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(reactingUser);
            var url = $"/api/notes/{note.Id}/reactions/{reactionType.Id}";

            var response = await Client.PostAsync(url, null); 

            Assert.Equal(HttpStatusCode.NoContent, response.StatusCode);

            //Check if changes were saved to db
            var reactionInDb = await DbContext.NoteReactions
                .AsNoTracking()
                .FirstOrDefaultAsync(
                    r => r.NoteId == note.Id && 
                    r.UserId == reactingUser.Id);

            Assert.NotNull(reactionInDb);
            Assert.Equal(reactionType.Id, reactionInDb.ReactionTypeId);
        }



        [Fact]
        public async Task AddNoteReaction_ShouldReturnBadRequest_WhenReactionAlreadyExists()
        {
            var noteOwner = DbContext.CreateTestUser("Owner");
            var reactingUser = DbContext.CreateTestUser("Reactor");
            var note = DbContext.CreateTestNote(user: noteOwner, subject: null);
          
            var reactionType = DbContext.CreateTestReactionType(name: "Like", iconUrl: "url");

            DbContext.CreateTestNoteReaction(note: note, user: reactingUser, reactionType: reactionType);

            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(reactingUser);
            var url = $"/api/notes/{note.Id}/reactions/{reactionType.Id}";

            //Try to react second time
            var response = await Client.PostAsync(url, null);

            Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        }



        [Fact]
        public async Task RemoveNoteReaction_ShouldReturnNoContent_AndRemoveFromDb()
        {
            var noteOwner = DbContext.CreateTestUser("Owner");
            var reactingUser = DbContext.CreateTestUser("Reactor");
            var note = DbContext.CreateTestNote(user: noteOwner, subject: null);
            var reactionType = DbContext.CreateTestReactionType(name: "Like", iconUrl: "url");

            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(reactingUser);
            var url = $"/api/notes/{note.Id}/reactions/{reactionType.Id}";

            var response = await Client.DeleteAsync(url);

            Assert.Equal(HttpStatusCode.NoContent, response.StatusCode);

            //Check if reaction was deleted
            var reactionInDb = await DbContext.NoteReactions
                .FirstOrDefaultAsync(r => r.NoteId == note.Id && r.UserId == reactingUser.Id);

            Assert.Null(reactionInDb);
        }



    }
}
