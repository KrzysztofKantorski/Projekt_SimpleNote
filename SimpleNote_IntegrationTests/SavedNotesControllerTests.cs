using Microsoft.EntityFrameworkCore;
using Projekt_SimpleNote.Dto.Community;
using SimpleNote_IntegrationTests.Helpers;
using System.Net;
using System.Net.Http.Json;

namespace SimpleNote_IntegrationTests
{
    public class SavedNotesControllerTests: BaseIntegrationTest
    {
        public SavedNotesControllerTests(CustomWebApplicationFactory factory) : base(factory)
        {
        }


        [Fact]
        public async Task GetSavedNotes_ShouldReturnOkAndSavedNotes_WhenValid()
        {
            var author = DbContext.CreateTestUser("AuthorUser");
            var savingUser = DbContext.CreateTestUser("SavingUser");

            var note1 = DbContext.CreateTestNote(author, title: "Saved Note 1", subject: null);
            var note2 = DbContext.CreateTestNote(author, title: "Saved Note 2", subject: null);
            var noteNotSaved = DbContext.CreateTestNote(author, title: "Not Saved Note", subject: null);

            //Add notes to saved
            note1.SavedByUsers.Add(savingUser);
            note2.SavedByUsers.Add(savingUser);

            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(savingUser); 
            var url = "/api/saved-notes";

            var response = await Client.GetAsync(url);

            Assert.Equal(HttpStatusCode.OK, response.StatusCode);

            var result = await response.Content.ReadFromJsonAsync<List<CommunityNoteListDto>>();
            Assert.NotNull(result);
            Assert.Equal(2, result.Count);

            Assert.Contains(result, n => n.Title == "Saved Note 1");
            Assert.Contains(result, n => n.Title == "Saved Note 2");
            Assert.DoesNotContain(result, n => n.Title == "Not Saved Note");
        }



        [Fact]
        public async Task SaveNoteFromCommunity_ShouldReturnNoContent_AndSaveToDb()
        {
            var author = DbContext.CreateTestUser("AuthorUser");
            var userSaving = DbContext.CreateTestUser("SavingUser");

            var note = DbContext.CreateTestNote(author, null);
            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(userSaving);
            var url = $"/api/saved-notes/{note.Id}";

            var response = await Client.PostAsync(url, null);

            Assert.Equal(HttpStatusCode.NoContent, response.StatusCode);

            //Check if action was saved
            var noteInDb = await DbContext.Notes
                .AsNoTracking()
                .Include(n => n.SavedByUsers)
                .FirstOrDefaultAsync(n => n.Id == note.Id);

            Assert.NotNull(noteInDb);
            Assert.Single(noteInDb.SavedByUsers);
            Assert.Equal(userSaving.Id, noteInDb.SavedByUsers.First().Id);
        }



        [Fact]
        public async Task SaveNoteFromCommunity_ShouldReturnBadRequest_WhenUserSavesOwnNote()
        {
            var user = DbContext.CreateTestUser();

            //User is the author
            var note = DbContext.CreateTestNote(user, null);
            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(user);
            var url = $"/api/saved-notes/{note.Id}";

            var response = await Client.PostAsync(url, null);

            Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        }



        [Fact]
        public async Task SaveNoteFromCommunity_ShouldReturnNoContent_WhenUserAlreadySavedNote()
        {
            var author = DbContext.CreateTestUser("AuthorUser");
            var userSaving = DbContext.CreateTestUser("SavingUser");

            var note = DbContext.CreateTestNote(author, null);

            note.SavedByUsers.Add(userSaving);
            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(userSaving);
            var url = $"/api/saved-notes/{note.Id}";

            var response = await Client.PostAsync(url, null);

            Assert.Equal(HttpStatusCode.NoContent, response.StatusCode);
        }




        [Fact]
        public async Task DeleteSavedNote_ShouldReturnNoContent_AndRemoveFromDb()
        {
            var author = DbContext.CreateTestUser("AuthorUser");
            var userRemoving = DbContext.CreateTestUser("RemovingUser");

            var note = DbContext.CreateTestNote(author, null);
            note.SavedByUsers.Add(userRemoving); // Tworzymy powiązanie
            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(userRemoving);
            var url = $"/api/saved-notes/{note.Id}";

            var response = await Client.DeleteAsync(url);

            Assert.Equal(HttpStatusCode.NoContent, response.StatusCode);

            //Verify if note was removed from saved 
            var noteInDb = await DbContext.Notes
                .AsNoTracking()
                .Include(n => n.SavedByUsers)
                .FirstOrDefaultAsync(n => n.Id == note.Id);

            Assert.NotNull(noteInDb);
            Assert.Empty(noteInDb.SavedByUsers);
        }

        [Fact]
        public async Task DeleteSavedNote_ShouldReturnNoContent_WhenNoteIsNotSaved()
        {
            var author = DbContext.CreateTestUser("AuthorUser");
            var randomUser = DbContext.CreateTestUser("RandomUser");

            var note = DbContext.CreateTestNote(author, null);

            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(randomUser);
            var url = $"/api/saved-notes/{note.Id}";

            var response = await Client.DeleteAsync(url);

            Assert.Equal(HttpStatusCode.NoContent, response.StatusCode);
        }
    }
}
