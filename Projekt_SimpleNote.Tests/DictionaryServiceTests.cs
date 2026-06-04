using MockQueryable.Moq;
using Moq;
using Projekt_SimpleNote.Data;
using Projekt_SimpleNote.Entities;
using Projekt_SimpleNote.Services;

namespace Projekt_SimpleNote.Tests
{
    public class DictionaryServiceTests
    {
        private Mock<ApplicationDbContext> CreateMockContext(List<Tag>? tags = null, List<Subject>? subjects = null)
        {
            var mockContext = new Mock<ApplicationDbContext>();

            if (tags != null)
                mockContext.Setup(c => c.Tags).Returns(tags.BuildMockDbSet().Object);

            if (subjects != null)
                mockContext.Setup(c => c.Subjects).Returns(subjects.BuildMockDbSet().Object);

            return mockContext;
        }


        //Check if GetTagsAsync returns tags ordered alphabetically and respects limit of 20 when no search term is provided
        [Fact]
        public async Task GetTagsAsync_ShouldReturnTags_OrderedAlphabetically_WithDefaultLimit()
        {
            //Test data
            var tagsData = new List<Tag>();

            //Generate 25 tags
            for (int i = 25; i >= 1; i--)
            {
                tagsData.Add(new Tag { Id = i, Name = $"Tag {i}" });
            }

            var mockContext = CreateMockContext(tags: tagsData);
            var service = new DictionaryService(mockContext.Object);

            //Should return tags ordered alphabetically and limited to 20
            var result = await service.GetTagsAsync(null);
            var resultList = result.ToList();

            //Check default limit
            Assert.Equal(20, resultList.Count);

            //Check if tags are ordered alphabetically
            Assert.Equal("Tag 1", resultList.First()); 
        }


        [Fact]
        public async Task GetTagsAsync_ShouldFilterTags_IgnoringCaseAndWhiteSpaces()
        {
            //Test data
            var tagsData = new List<Tag>
            {
                new Tag { Id = 1, Name = "C# Programming" },
                new Tag { Id = 2, Name = "Java Basics" },
                new Tag { Id = 3, Name = "Advanced c#" }
            };

            var mockContext = CreateMockContext(tags: tagsData);
            var service = new DictionaryService(mockContext.Object);

            //Test search term with different case and extra white spaces
            var result = await service.GetTagsAsync("  C#  ");
            var resultList = result.ToList();

            //Should return only tags that contain "C#" ignoring case and white spaces
            Assert.Equal(2, resultList.Count); 
            Assert.Contains("Advanced c#", resultList);
            Assert.Contains("C# Programming", resultList);
        }


        [Fact]
        public async Task GetSubjectsAsync_ShouldReturnSubjects_OrderedAlphabetically_WithCustomLimit()
        {
            //Test data
            var subjectsData = new List<Subject>
            {
                new Subject { Id = 1, Name = "Zend Framework" },
                new Subject { Id = 2, Name = "Algebra" },
                new Subject { Id = 3, Name = "Physics" },
                new Subject { Id = 4, Name = "Biology" }
            };

            var mockContext = CreateMockContext(subjects: subjectsData);
            var service = new DictionaryService(mockContext.Object);

            // Set limit to 2
            var result = await service.GetSubjectsAsync(null, limit: 2);
            var resultList = result.ToList();

            //Only 2 subjects should be returned
            Assert.Equal(2, resultList.Count);
            Assert.Equal("Algebra", resultList[0]); 
            Assert.Equal("Biology", resultList[1]);
        }

        [Fact]
        public async Task GetSubjectsAsync_ShouldFilterSubjects_IgnoringCaseAndWhiteSpaces()
        {
            //Test data
            var subjectsData = new List<Subject>
            {
                new Subject { Id = 1, Name = "Mathematics" },
                new Subject { Id = 2, Name = "Discrete Math" },
                new Subject { Id = 3, Name = "History" }
            };

            var mockContext = CreateMockContext(subjects: subjectsData);
            var service = new DictionaryService(mockContext.Object);

            var result = await service.GetSubjectsAsync("mAtH");
            var resultList = result.ToList();

            Assert.Equal(2, resultList.Count);
            Assert.Contains("Discrete Math", resultList);
            Assert.Contains("Mathematics", resultList);
        }
    }

}
