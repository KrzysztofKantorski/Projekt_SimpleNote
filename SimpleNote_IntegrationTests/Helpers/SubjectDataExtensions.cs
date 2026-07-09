using Projekt_SimpleNote.Data;
using Projekt_SimpleNote.Entities;

namespace SimpleNote_IntegrationTests.Helpers
{
    public static class SubjectDataExtensions
    {
        public static Subject CreateTestSubject(
            this ApplicationDbContext context,
            string name = "NewSubject") 
        {
            var testSubject = new Subject
            {
                Name = name
            };

            context.Subjects.Add(testSubject);

            return testSubject;
        }
    }
}
