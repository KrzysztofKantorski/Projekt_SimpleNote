using MockQueryable.Moq;
using Moq;
using Projekt_SimpleNote.Data;
using Projekt_SimpleNote.Entities;
using Projekt_SimpleNote.Services;

namespace Projekt_SimpleNote.Tests
{
    public class CommunityServiceTests
    {
        private Mock<ApplicationDbContext> CreateMockContext(List<Note> notesData)
        {
            var mockDbSet = notesData.BuildMockDbSet();
            var mockContext = new Mock<ApplicationDbContext>();
            mockContext.Setup(c => c.Notes).Returns(mockDbSet.Object);
            return mockContext;
        }


        //Check if GetPublicNotesAsync returns only public notes and ignores current user's notes
        [Fact]
        public async Task GetPublicNotesAsync_ShouldReturnOnlyPublicNotes_AndIgnoreOwnNotes()
        {
            //Test data
            var currentUserId = 1L;
            var author = new User { Id = 2, Username = "Author" };
            var me = new User { Id = currentUserId, Username = "Me" };

            var data = new List<Note>
            {
                new Note 
                { 
                    Id = 1, 
                    Title = "Public Note", 
                    IsPublic = true, 
                    UserId = 2, 
                    User = author, 
                    Tags = new List<Tag>() 
                },

                new Note 
                { 
                    Id = 2, 
                    Title = "Private Note", 
                    IsPublic = false, 
                    UserId = 2, 
                    User = author, 
                    Tags = new List<Tag>() 
                },

                new Note 
                { 
                    Id = 3, 
                    Title = "My Own Public Note", 
                    IsPublic = true, 
                    UserId = currentUserId, 
                    User = me, 
                    Tags = new List<Tag>() 
                }
            };

            var mockContext = CreateMockContext(data);
            var service = new CommunityService(mockContext.Object);

            var result = await service.GetPublicNotesAsync(null, null, null, currentUserId);
            var resultList = result.ToList();


            Assert.Single(resultList);

            //Only first note must be returned
            Assert.Equal("Public Note", resultList.First().Title);
        }

        //Check if GetPublicNotesAsync correctly filters notes by phrase in title, subject name and tag name
        [Fact]
        public async Task GetPublicNotesAsync_ShouldFilterCorrectly_ByPhraseSubjectAndTag()
        {
            //Test data
            var currentUserId = 1L;
            var author = new User { Id = 2, Username = "Author" };
            var targetSubject = new Subject { Id = 1, Name = "Math" };
            var targetTag = new Tag { Id = 1, Name = "Algebra" };

            var data = new List<Note>
            {
                //Valid note
                new Note
                {
                    Id = 1, 
                    Title = "Linear Algebra Guide", 
                    IsPublic = true, 
                    UserId = 2, 
                    User = author,
                    Subject = targetSubject, 
                    Tags = new List<Tag> { targetTag }, 
                    CreatedAt = DateTime.UtcNow
                },

                //Note with incorrect subject (does not exist in db)
                new Note
                {
                    Id = 2, 
                    Title = "Linear Algebra Guide", 
                    IsPublic = true,
                    UserId = 2, 
                    User = author,
                    Subject = new Subject { Name = "History" }, 
                    Tags = new List<Tag> { targetTag }, 
                    CreatedAt = DateTime.UtcNow
                },

                //Note with non-existing title (phrase does not match)
                new Note
                {
                    Id = 3, 
                    Title = "Cooking Recipes", 
                    IsPublic = true, 
                    UserId = 2, 
                    User = author,
                    Subject = targetSubject, 
                    Tags = new List<Tag> { targetTag }, 
                    CreatedAt = DateTime.UtcNow
                }
            };

            var mockContext = CreateMockContext(data);
            var service = new CommunityService(mockContext.Object);
            var result = await service.GetPublicNotesAsync("linear ", "Math", "Algebra", currentUserId);
            var resultList = result.ToList();

            //Only first note matches all criteria
            Assert.Single(resultList);
            Assert.Equal(1, resultList.First().Id);
        }


        //Check if GetPublicNotesAsync returns maximum 50 notes ordered by newest
        [Fact]
        public async Task GetPublicNotesAsync_ShouldReturnMaximum50Notes_OrderedByNewest()
        {
            //Test data
            var currentUserId = 1L;
            var author = new User { Id = 2, Username = "Author" };
            var data = new List<Note>();

            //Generete more than 50 public notes to test the limit and ordering
            for (int i = 1; i <= 52; i++)
            {
                data.Add(new Note
                {
                    Id = i,
                    Title = $"Note {i}",
                    IsPublic = true,
                    UserId = 2,
                    User = author,
                    Tags = new List<Tag>(),
                    CreatedAt = DateTime.UtcNow.AddMinutes(i)
                });
            }

            var mockContext = CreateMockContext(data);
            var service = new CommunityService(mockContext.Object);

            // Act
            var result = await service.GetPublicNotesAsync(null, null, null, currentUserId);
            var resultList = result.ToList();

            //Should return only 50 notes
            Assert.Equal(50, resultList.Count);

            //First note should be the newest one (Note 52)
            Assert.Equal("Note 52", resultList.First().Title); 
        }

        //Check if GetPublicNoteByIdAsync returns null when note is not found or is private
        [Fact]
        public async Task GetPublicNoteByIdAsync_ShouldReturnNull_WhenNoteNotFoundOrPrivate()
        {
            //Test data
            var data = new List<Note>
            {
                new Note { Id = 1, Title = "Private Note", IsPublic = false } 
            };

            var mockContext = CreateMockContext(data);
            var service = new CommunityService(mockContext.Object);

            //Trying to get a private note
            var result = await service.GetPublicNoteByIdAsync(1, 99);

            //Trying to get a non-existing note
            var result2 = await service.GetPublicNoteByIdAsync(999, 99);

            //Should return null in both cases
            Assert.Null(result);
            Assert.Null(result2);
        }

        //Check if GetPublicNoteByIdAsync returns note details when the user saved this note
        [Fact]
        public async Task GetPublicNoteByIdAsync_ShouldReturnDetailsWithIsSavedTrue_WhenUserSavedThisNote()
        {
            //Test data
            var currentUserId = 1L;
            var author = new User { Id = 2, Username = "Author" };
            var me = new User { Id = currentUserId, Username = "Me" };

            var note = new Note
            {
                Id = 1,
                Title = "Awesome Note",
                Content = "Content",
                IsPublic = true,
                UserId = 2,
                User = author,
                Subject = new Subject { Name = "IT" },
                Tags = new List<Tag>(),
                SavedByUsers = new List<User> { me }
            };

            var mockContext = CreateMockContext(new List<Note> { note });
            var service = new CommunityService(mockContext.Object);

            var result = await service.GetPublicNoteByIdAsync(1, currentUserId);

            //Should return note details
            Assert.NotNull(result);
            Assert.Equal("Awesome Note", result!.Title);

            //Check if IsSavedByCurrentUser is true
            Assert.True(result.IsSavedByCurrentUser); 
        }

    }

}
