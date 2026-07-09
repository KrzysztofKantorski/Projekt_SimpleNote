using Projekt_SimpleNote.Dto.Community;
using Projekt_SimpleNote.Entities;
using SimpleNote_IntegrationTests.Helpers;
using System.Net;
using System.Net.Http.Json;

namespace SimpleNote_IntegrationTests
{
    public class CommunityControllerTests: BaseIntegrationTest
    {

        public CommunityControllerTests(CustomWebApplicationFactory factory) : base(factory)
        {
        }



        [Fact]
        public async Task GetCommunityNotes_ShouldReturnOkAndNotes_WhenUserAuthorized()
        {
            var regularUser_1 = DbContext.CreateTestUser(username: "user_1", role: "User");
            var regularUser_2 = DbContext.CreateTestUser(username: "user_2", role: "User");

            var note_1 = DbContext.CreateTestNote(
               title: "Test note",
               content: "Test note content",
               user: regularUser_2,
               subject: new Subject
               {
                   Name = "Test subject"
               }
           );

            var note_2 = DbContext.CreateTestNote(
               title: "Test note_2",
               content: "Test note content",
               user: regularUser_2,
               subject: new Subject
               {
                   Name = "Test subject_2"
               }
           );


            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(regularUser_1);


            var url = $"/api/community/notes";

            var response = await Client.GetAsync(url);

            Assert.Equal(HttpStatusCode.OK, response.StatusCode);

            var result = await response.Content.ReadFromJsonAsync<List<CommunityNoteListDto>>();

            Assert.NotNull(result);
            Assert.Equal(2, result.Count);

            Assert.Contains(result, n => n.Title == "Test note");
            Assert.Contains(result, n => n.Title == "Test note_2");
        }



        [Fact]
        public async Task GetCommuntityNotes_ShouldReturnOkAndNotes_WhenUserUnAuthorized() 
        {
            var regularUser_2 = DbContext.CreateTestUser(username: "user_2", role: "User");

            var note_1 = DbContext.CreateTestNote(
               title: "Test note",
               content: "Test note content",
               user: regularUser_2,
               subject: new Subject
               {
                   Name = "Test subject"
               }
           );

            var note_2 = DbContext.CreateTestNote(
               title: "Test note_2",
               content: "Test note content",
               user: regularUser_2,
               subject: new Subject
               {
                   Name = "Test subject_2"
               }
           );


            await DbContext.SaveChangesAsync();

            var url = $"/api/community/notes";

            var response = await Client.GetAsync(url);

            Assert.Equal(HttpStatusCode.OK, response.StatusCode);

            var result = await response.Content.ReadFromJsonAsync<List<CommunityNoteListDto>>();

            Assert.NotNull(result);
            Assert.Equal(2, result.Count);

            Assert.Contains(result, n => n.Title == "Test note");
            Assert.Contains(result, n => n.Title == "Test note_2");
        }




        [Fact]
        public async Task GetCommunityNoteDetails_ShouldReturnOkAndNoteDetails_WhenUserAuthorized() 
        {
            var regularUser_1 = DbContext.CreateTestUser(username: "user_1", role: "User");
            var regularUser_2 = DbContext.CreateTestUser(username: "user_2", role: "User");

            var note_1 = DbContext.CreateTestNote(
               title: "Test note",
               content: "Test note content",
               user: regularUser_2,
               subject: new Subject
               {
                   Name = "Test subject"
               }
           );

            var note_2 = DbContext.CreateTestNote(
               title: "Test note_2",
               content: "Test note content",
               user: regularUser_2,
               subject: new Subject
               {
                   Name = "Test subject_2"
               }
            );

            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(regularUser_1);

            var url = $"/api/community/notes/{note_2.Id}";

            var response = await Client.GetAsync(url);

            Assert.Equal(HttpStatusCode.OK, response.StatusCode);

            var result = await response.Content.ReadFromJsonAsync<CommunityNoteDetailsDto>();

            Assert.NotNull(result);

            Assert.Equal("Test note_2", result.Title);
        }



        [Fact]
        public async Task GetCommunityDetaile_ShouldReturnBadRequest_WhenNoteIsNull()
        {
            var regularUser_1 = DbContext.CreateTestUser(username: "user_1", role: "User");

            int fakeNoteId = 999;

            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(regularUser_1);

            var url = $"/api/community/notes/{fakeNoteId}";

            var response = await Client.GetAsync(url);

            Assert.Equal(HttpStatusCode.NoContent, response.StatusCode);

        }
    }
}
