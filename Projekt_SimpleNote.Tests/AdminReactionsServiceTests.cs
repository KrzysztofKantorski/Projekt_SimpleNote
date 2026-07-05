using MockQueryable.Moq;
using Moq;
using Projekt_SimpleNote.Data;
using Projekt_SimpleNote.Dto.Admin;
using Projekt_SimpleNote.Dto.Pagination;
using Projekt_SimpleNote.Entities;
using Projekt_SimpleNote.Services;

namespace Projekt_SimpleNote.Tests
{
    public class AdminReactionsServiceTests
    {
        private Mock<ApplicationDbContext> CreateMockContext(List<ReactionType> reactionsData)
        {
            var mockDbSet = reactionsData.BuildMockDbSet();

            var mockContext = new Mock<ApplicationDbContext>();
            mockContext.Setup(c => c.ReactionTypes).Returns(mockDbSet.Object);

            return mockContext;
        }


        //Check if GetAllReactionTypesAsync returns all reaction types as DTOs
        [Fact]
        public async Task GetAllReactionTypesAsync_ShouldReturnAllReactions_AsDto()
        {
            var paginationParams = new PaginationParamsDto( 1, 10 );
            var data = new List<ReactionType>
            {
                new ReactionType { Id = 1, Name = "Like", IconUrl = "assets/icons/like.png" },
                new ReactionType { Id = 2, Name = "Love", IconUrl = "assets/icons/love.png" }
            };

            var mockContext = CreateMockContext(data);

            var service = new AdminReactionsSerwice(mockContext.Object);

            var result = await service.GetAllReactionTypesAsync(paginationParams);
            var resultList = result.Items.ToList();

            Assert.Equal(2, resultList.Count);
            Assert.Equal("Like", resultList[0].Name);
            Assert.Equal("assets/icons/love.png", resultList[1].IconUrl);

            //Pagination
            Assert.Equal(2, result.TotalCount);
            Assert.Equal(1, result.CurrentPage);
            Assert.Equal(10, result.PageSize);
            Assert.Equal(1, result.TotalPages);
        }


        //Check if AddReactionTypeAsync adds new reaction type when name is unique
        [Fact]
        public async Task AddReactionTypeAsync_ShouldAddReaction_WhenNameIsUnique()
        {
            var data = new List<ReactionType>();
            var mockContext = CreateMockContext(data);
            var service = new AdminReactionsSerwice(mockContext.Object);
            var newDto = new CreateReactionTypeDto("Wow", "assets/images/wow.png");

            var result = await service.AddReactionTypeAsync(newDto);

            Assert.True(result.Success);
            Assert.Equal("Wow", result.Data!.Name);
            mockContext.Verify(m => m.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
        }


        //Check if AddReactionTypeAsync returns false when reaction name already exists
        [Fact]
        public async Task AddReactionTypeAsync_ShouldReturnFalse_WhenNameAlreadyExists()
        {
            var data = new List<ReactionType>
            {
                new ReactionType { Id = 1, Name = "Like" }
            };

            var mockContext = CreateMockContext(data);
            var service = new AdminReactionsSerwice(mockContext.Object);


            //Add duplicate reaction
            var newDto = new CreateReactionTypeDto("like", "like2.png");

            var result = await service.AddReactionTypeAsync(newDto);

            Assert.False(result.Success);
            Assert.Null(result.Data);
            //No data should be saved to db
            mockContext.Verify(m => m.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Never);
        }


        //Check if UpdateSubjectAsync updates reaction type when data is valid
        [Fact]
        public async Task UpdateSubjectAsync_ShouldUpdateReaction_WhenDataIsValid()
        {
            var targetReaction = new ReactionType { Id = 1, Name = "OldName", IconUrl = "asstets/images/old.png" };
            var data = new List<ReactionType> { targetReaction };
            var mockContext = CreateMockContext(data);
            var service = new AdminReactionsSerwice(mockContext.Object);

            var updateDto = new CreateReactionTypeDto("NewName", "new.png");

            var result = await service.UpdateSubjectAsync(1, updateDto);


            Assert.True(result.Success);
            Assert.Equal("NewName", result.Data!.Name);

            //Check if the reaction in the db was updated
            Assert.Equal("NewName", targetReaction.Name);
            mockContext.Verify(m => m.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
        }

        //Check if UpdateSubjectAsync returns false when reaction with given id is not found
        [Fact]
        public async Task UpdateSubjectAsync_ShouldReturnFalse_WhenReactionNotFound()
        {
            var data = new List<ReactionType>();
            var mockContext = CreateMockContext(data);
            var service = new AdminReactionsSerwice(mockContext.Object);

            var updateDto = new CreateReactionTypeDto("NewName", "new.png");

            //Update non-existing reaction
            var result = await service.UpdateSubjectAsync(99, updateDto); 

            Assert.False(result.Success);
            mockContext.Verify(m => m.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Never);
        }

        //Check if UpdateSubjectAsync returns false when encountering name conflict
        [Fact]
        public async Task UpdateSubjectAsync_ShouldReturnFalse_WhenNameConflict()
        {
            // Arrange (Edge Case 2: Konflikt nazw z inną reakcją)
            var data = new List<ReactionType>
            {
                new ReactionType { Id = 1, Name = "Like" },
                new ReactionType { Id = 2, Name = "Love" }
            };
            var mockContext = CreateMockContext(data);
            var service = new AdminReactionsSerwice(mockContext.Object);

            //Name conflict with existing reaction
            var updateDto = new CreateReactionTypeDto ("Love", "/assets/images/new.png" );

            var result = await service.UpdateSubjectAsync(1, updateDto);

            Assert.False(result.Success);
            Assert.Equal("This subject alerdy exists", result.Message); 
        }


        //Check if DeleteReactionTypeAsync removes reaction type when it is not used in any notes
        [Fact]
        public async Task DeleteReactionTypeAsync_ShouldRemoveReaction_WhenNotUsedInNotes()
        {
            var reaction = new ReactionType
            {
                Id = 1,
                //Nobody used this reaction in any note
                Reactions = new List<NoteReaction>() 
            };

            var data = new List<ReactionType> { reaction };
            var mockContext = CreateMockContext(data);
            var service = new AdminReactionsSerwice(mockContext.Object);

            var result = await service.DeleteReactionTypeAsync(1);

            Assert.True(result.Success);
            mockContext.Verify(m => m.ReactionTypes.Remove(reaction), Times.Once);
            mockContext.Verify(m => m.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
        }


        [Fact]
        public async Task DeleteReactionTypeAsync_ShouldReturnFalse_WhenUsedInNotes()
        {
            var reaction = new ReactionType
            {
                Id = 1,

                //Someone used this reaction
                Reactions = new List<NoteReaction> { new NoteReaction() }
            };
            var data = new List<ReactionType> { reaction };
            var mockContext = CreateMockContext(data);
            var service = new AdminReactionsSerwice(mockContext.Object);

            var result = await service.DeleteReactionTypeAsync(1);

            Assert.False(result.Success);
            Assert.Equal("This reaction is used in notes. It cannot be deleted", result.Message);

            // Check if deletion was cancelled
            mockContext.Verify(m => m.ReactionTypes.Remove(It.IsAny<ReactionType>()), Times.Never);
            mockContext.Verify(m => m.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Never);
        }
    }
}
