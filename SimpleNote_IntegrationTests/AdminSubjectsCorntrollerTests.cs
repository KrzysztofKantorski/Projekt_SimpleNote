using Microsoft.EntityFrameworkCore;
using Projekt_SimpleNote.Dto.Admin;
using Projekt_SimpleNote.Dto.Pagination;
using Projekt_SimpleNote.Entities;
using SimpleNote_IntegrationTests.Helpers;
using System.Net;
using System.Net.Http.Json;

namespace SimpleNote_IntegrationTests
{
    public class AdminSubjectsCorntrollerTests: BaseIntegrationTest
    {
        public AdminSubjectsCorntrollerTests(CustomWebApplicationFactory factory): base(factory)
        {
        }



        //Get all subjects as admin
        [Fact]
        public async Task GetAllSubjects_ShouldReturnOkAndPagedList_WhenUserIsAdmin()
        {
            //Create test data
          
            var admin = DbContext.CreateTestUser(role: "Admin");

            for (int i = 1; i <= 5; i++)
            {
                DbContext.CreateTestSubject(name: $"Subject_{i}");
            }

            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(admin);
            var url = "/api/admin/subjects?pageNumber=1&pageSize=10";

            //Send request
            var response = await Client.GetAsync(url);

            //Check status code
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);

            var result = await response.Content.ReadFromJsonAsync<PagedResult<SubjectDto>>();

            Assert.NotNull(result);
            Assert.Equal(5, result.TotalCount);
        }



        //Get all subjects as regular user
        [Fact]
        public async Task GetAllSubjects_ShouldReturnForbidden_WhenUserIsRegularUser()
        {
         
            var regularUser = DbContext.CreateTestUser(role: "User");

            Client.AuthenticateAs(regularUser); 
            var url = "/api/admin/subjects?pageNumber=1&pageSize=10";

            //Send request
            var response = await Client.GetAsync(url);

            //Check status code
            Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
        }



        [Fact]
        public async Task AddSubject_ShouldReturnOk_AndSaveToDatabase_WhenValid()
        {

            var admin = DbContext.CreateTestUser(role: "Admin");

            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(admin);

            var newSubjectDto = new SubjectRequestDto("Physics");

            var url = "/api/admin/subjects";

            //Send request
            var response = await Client.PostAsJsonAsync(url, newSubjectDto);

            //Check status code
            Assert.Equal(HttpStatusCode.Created, response.StatusCode); 

            //Check if the subject was saved in the database
            var savedSubject = await DbContext.Subjects.FirstOrDefaultAsync(s => s.Name == "Physics");

            Assert.NotNull(savedSubject);
        }


        //Add subject with existing name
        [Fact]
        public async Task AddSubject_ShouldReturnBadRequest_WhenSubjectNameAlreadyExists()
        {
            var admin = DbContext.CreateTestUser(role: "Admin");

            DbContext.CreateTestSubject(name: "Physics");

            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(admin);

            // Try to add a subject with the same name
            var duplicateSubjectDto = new SubjectRequestDto("physics");

            var url = "/api/admin/subjects";

            var response = await Client.PostAsJsonAsync(url, duplicateSubjectDto);

            Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        }



        //Update subject as admin
        [Fact]
        public async Task UpdateSubject_ShouldReturnOk_AndUpdateInDatabase()
        {
            //Create test data
            var admin = DbContext.CreateTestUser(role: "Admin");

            var existingSubject = DbContext.CreateTestSubject(name: "Old name");

            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(admin);

            var updateDto = new SubjectRequestDto("New Name");

            var url = $"/api/admin/subjects/{existingSubject.Id}";

            var response = await Client.PutAsJsonAsync(url, updateDto);

            Assert.Equal(HttpStatusCode.OK, response.StatusCode);

            var updatedInDb = await DbContext.Subjects
                .AsNoTracking()
                .FirstOrDefaultAsync(s => s.Id == existingSubject.Id);

            Assert.NotNull(updatedInDb);
            Assert.Equal(updateDto.Name, updatedInDb.Name);
        }


        //Remove subject as admin
        [Fact]
        public async Task DeleteSubject_ShouldReturnOk_AndRemoveFromDatabase_WhenUnused()
        {
         
            var admin = DbContext.CreateTestUser(role: "Admin");

            var subjectToDelete = DbContext.CreateTestSubject(name: "To Be Deleted");

            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(admin);
            var url = $"/api/admin/subjects/{subjectToDelete.Id}";

            var response = await Client.DeleteAsync(url);

            Assert.Equal(HttpStatusCode.NoContent, response.StatusCode); 

            //Check if the subject was removed from the database
            var deletedSubject = await DbContext.Subjects.FirstOrDefaultAsync(s => s.Id == subjectToDelete.Id);
            Assert.Null(deletedSubject);
        }


        //Remove subject used in notes
        [Fact]
        public async Task DeleteSubject_ShouldReturnBadRequest_WhenSubjectIsUsedInNotes()
        {
           
            var admin = DbContext.CreateTestUser(role: "Admin");
           
            var testSubject = DbContext.CreateTestSubject(name: "Biology");

            var testNote = DbContext.CreateTestNote(
                title: "Test",
                content: "Content",
                subject: testSubject,
                user: admin
            );

            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(admin);

            var url = $"/api/admin/subjects/{testSubject.Id}";

            var response = await Client.DeleteAsync(url);

            Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);

            //Subject must still exist in db
            var subjectStillInDb = await DbContext.Subjects.FirstOrDefaultAsync(s => s.Id == testSubject.Id);
            Assert.NotNull(subjectStillInDb);
        }
    }
}
