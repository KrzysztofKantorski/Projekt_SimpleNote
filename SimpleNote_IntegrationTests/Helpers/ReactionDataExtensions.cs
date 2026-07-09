using Projekt_SimpleNote.Data;
using Projekt_SimpleNote.Dto.Admin;
using Projekt_SimpleNote.Entities;

namespace SimpleNote_IntegrationTests.Helpers
{
    public static class ReactionDataExtensions
    {
        public static ReactionType CreateTestReactionType(
            this ApplicationDbContext context,
            string name= "NewReaction",
            string iconUrl= "http://example.com/newicon.png")
        {
            var testReactionType = new ReactionType
            {
                Name = name,
                IconUrl = iconUrl
            };

            context.ReactionTypes.Add(testReactionType);

            return testReactionType;
        }


        //Create new reaction for POST request
        public static CreateReactionTypeDto CreateTestReactionTypeDto(
            this ApplicationDbContext context,
            string name = "NewReaction",
            string iconUrl = "http://example.com/newicon.png")
        {
            var testReactionType = new CreateReactionTypeDto
            (
                Name : name,
                IconUrl : iconUrl
            );

            return testReactionType;
        }
    }
}
