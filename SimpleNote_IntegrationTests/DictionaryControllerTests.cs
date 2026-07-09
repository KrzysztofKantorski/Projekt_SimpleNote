using SimpleNote_IntegrationTests.Helpers;
using System.Net.Http.Json;

namespace SimpleNote_IntegrationTests
{
    public class DictionaryControllerTests : BaseIntegrationTest
    {
        public DictionaryControllerTests(CustomWebApplicationFactory factory) : base(factory)
        {
        }

        [Fact]
        public async Task GetTags_ShouldReturnOkAndTags_WhenValid()
        {
            var user = DbContext.CreateTestUser();

            for (int i = 0; i < 10; i++)
            {
                DbContext.CreateTestTag($"Test_tag_{i}");
            }

            DbContext.CreateTestTag("Different tag");

            await DbContext.SaveChangesAsync();

            Client.AuthenticateAs(user);

            var search = "Test";
            var url = $"/api/dictionaries/tags?search={search}";

            //Send request
            var response = await Client.GetAsync(url);

            var tagsFromApi = await response.Content.ReadFromJsonAsync<List<string>>();

            Assert.NotNull(tagsFromApi);
            Assert.Equal(10, tagsFromApi.Count);
            Assert.Contains(search, tagsFromApi.First());
        }
    }
}
