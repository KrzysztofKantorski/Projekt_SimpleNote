using Projekt_SimpleNote.Data;
using Projekt_SimpleNote.Entities;


namespace SimpleNote_IntegrationTests.Helpers
{
    public static class TagDataExtensions
    {
        public static Tag CreateTestTag(
            this ApplicationDbContext context,
            string name = "Test tag")
        {

            var testTag = new Tag
            {
                Name = name
            };

            context.Tags.Add(testTag);
            return testTag;
        }
    }
}
