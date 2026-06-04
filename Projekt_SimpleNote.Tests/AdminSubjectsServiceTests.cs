using MockQueryable.Moq;
using Moq;
using Projekt_SimpleNote.Data;
using Projekt_SimpleNote.Entities;
using Projekt_SimpleNote.Services;

namespace Projekt_SimpleNote.Tests
{
    public class AdminSubjectsServiceTests
    {
        private Mock<ApplicationDbContext> CreateMockContext(List<Subject> subjectsData)
        {
            var mockDbSet = subjectsData.BuildMockDbSet();

            var mockContext = new Mock<ApplicationDbContext>();
            mockContext.Setup(c => c.Subjects).Returns(mockDbSet.Object);

            return mockContext;
        }

        //Check if GetAllSubjectsAsync returns all subjects as DTOs
        [Fact]
        public async Task GetAllSubjectsAsync_ShouldReturnAllSubjects_AsDto()
        {
            //Sample subject data
            var data = new List<Subject>
            {
                new Subject { Id = 1, Name = "Math" },
                new Subject { Id = 2, Name = "History" }
            };

            var mockContext = CreateMockContext(data);
            var service = new AdminSubjectsService(mockContext.Object);
            var result = await service.GetAllSubjectsAsync();
            var resultList = result.ToList();

            //Verify that the result contains correct number of subjects and correct data
            Assert.Equal(2, resultList.Count);
            Assert.Equal("Math", resultList[0].Name);
            Assert.Equal("History", resultList[1].Name);

        }

        //Check if AddSubjectAsync adds new subject when name is unique
        [Fact]
        public async Task AddSubjectAsync_ShouldAddSubject_WhenNameIsUnique()
        {
            var data = new List<Subject>();
            var mockContext = CreateMockContext(data);
            var service = new AdminSubjectsService(mockContext.Object);
            var newDto = new Dto.Admin.SubjectRequestDto("Physics");
            var result = await service.AddSubjectAsync(newDto);
            Assert.True(result.Success);
            Assert.Equal("Physics", result.Data!.Name);
            mockContext.Verify(m => m.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
        }

        //Check if AddSubjectAsync does not add subject when name is not unique
        [Fact]
        public async Task AddSubjectAsync_ShouldNotAddSubject_WhenNameIsNotUnique()
        {
            var data = new List<Subject>
            {
                new Subject { Id = 1, Name = "Math" }
            };
            var mockContext = CreateMockContext(data);
            var service = new AdminSubjectsService(mockContext.Object);
            var newDto = new Dto.Admin.SubjectRequestDto("Math");
            var result = await service.AddSubjectAsync(newDto);
            Assert.False(result.Success);
            Assert.Equal("Subject with this name alerdy exists", result.Message);
            mockContext.Verify(m => m.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Never);
        }


        //Check if UpdateSubjectAsync updates subject when id exists and name is unique
        [Fact]
        public async Task UpdateSubjectAsync_ShouldUpdateSubject_WhenIdExistsAndNameIsUnique()
        {
            var data = new List<Subject>
            {
                new Subject { Id = 1, Name = "Math" },
                new Subject { Id = 2, Name = "History" }
            };
            var mockContext = CreateMockContext(data);
            var service = new AdminSubjectsService(mockContext.Object);
            var updateDto = new Dto.Admin.SubjectRequestDto("Physics");
            var result = await service.UpdateSubjectAsync(1, updateDto);
            Assert.True(result.Success);
            Assert.Equal("Physics", result.Data!.Name);
            mockContext.Verify(m => m.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
        }

        //Check if UpdateSubjectAsync does not update subject when id does not exist
        [Fact]
        public async Task UpdateSubjectAsync_ShouldNotUpdateSubject_WhenIdDoesNotExist()
        {
            var data = new List<Subject>
            {
                new Subject { Id = 1, Name = "Math" }
            };
            var mockContext = CreateMockContext(data);
            var service = new AdminSubjectsService(mockContext.Object);
            var updateDto = new Dto.Admin.SubjectRequestDto("Physics");

            //Subject with id 99 does not exist
            var result = await service.UpdateSubjectAsync(99, updateDto);

            Assert.False(result.Success);
            Assert.Equal("Subject does not exist.", result.Message);
            mockContext.Verify(m => m.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Never);

        }


        //Check name conflict in UpdateSubjectAsync
        [Fact]
        public async Task UpdateSubjectAsync_ShouldNotUpdateSubject_WhenNameIsNotUnique()
        {
            var data = new List<Subject>
            {
                new Subject { Id = 1, Name = "Math" },
                new Subject { Id = 2, Name = "History" }
            };
            var mockContext = CreateMockContext(data);
            var service = new AdminSubjectsService(mockContext.Object);
            var updateDto = new Dto.Admin.SubjectRequestDto("History");

            //Name conflict with subject Id=2
            var result = await service.UpdateSubjectAsync(1, updateDto);
            Assert.False(result.Success);
            Assert.Equal("Subject with this name alerdy exists", result.Message);
            mockContext.Verify(m => m.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Never);

        }

        //Check if DeleteSubjectAsync deletes subject when id exists
        [Fact]
        public async Task DeleteSubjectAsync_ShouldDeleteSubject_WhenIdExists()
        {
            var data = new List<Subject>
            {
                new Subject { Id = 1, Name = "Math" }
            };
            var mockContext = CreateMockContext(data);
            var service = new AdminSubjectsService(mockContext.Object);
            var result = await service.DeleteSubjectAsync(1);
            Assert.True(result.Success);
            Assert.Equal("Subject deleted", result.Message);
            mockContext.Verify(m => m.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
        }


        //Check if DeleteSubjectAsync does not delete subject when id does not exist
        [Fact]
        public async Task DeleteSubjectAsync_ShouldNotDeleteSubject_WhenIdDoesNotExist()
        {
            var data = new List<Subject>
            {
                new Subject { Id = 1, Name = "Math" }
            };
            var mockContext = CreateMockContext(data);
            var service = new AdminSubjectsService(mockContext.Object);

            //Subject with id 99 does not exist
            var result = await service.DeleteSubjectAsync(99);
            Assert.False(result.Success);
            Assert.Equal("Subject does not exist.", result.Message);
            mockContext.Verify(m => m.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Never);
        }

        //Check if DeleteSubjectAsync does not delete subject when it is used in notes
        [Fact]
        public async Task DeleteSubjectAsync_ShouldNotDeleteSubject_WhenSubjectUsedInNotes()
        {
            var data = new List<Subject>
            {
                new Subject { 
                    Id = 1, 
                    Name = "Math", 
                    Notes = new List<Note> 
                    { 
                        new Note { Id = 1 } 
                    } 
                }
            };

            var mockContext = CreateMockContext(data);
            var service = new AdminSubjectsService(mockContext.Object);
            var result = await service.DeleteSubjectAsync(1);
            Assert.False(result.Success);
            Assert.Equal("This subject is used in notes. It cannot be removed.", result.Message);
            mockContext.Verify(m => m.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Never);
        }
    }
}
