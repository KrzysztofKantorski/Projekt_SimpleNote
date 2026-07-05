using MockQueryable.Moq;
using Moq;
using Projekt_SimpleNote.Data;
using Projekt_SimpleNote.Dto.Pagination;
using Projekt_SimpleNote.Entities;
using Projekt_SimpleNote.Services;

namespace Projekt_SimpleNote.Tests
{
    public class AdminUsersServiceTests
    {

        private Mock<ApplicationDbContext> CreateMockContext(List<User> userData, List<RefreshToken>? tokensData = null)
        {
            var mockDbSet = userData.BuildMockDbSet();

            var mockContext = new Mock<ApplicationDbContext>();
            mockContext.Setup(c => c.Users).Returns(mockDbSet.Object);

            if (tokensData != null)
            {
                var mockTokensDbSet = tokensData.BuildMockDbSet();
                mockContext.Setup(c => c.RefreshTokens).Returns(mockTokensDbSet.Object);
            }

            return mockContext;
        }

        //Check if GetAllUsersAsync returns all users as DTOs
        [Fact]
        public async Task GetAllUsersAsync_ShouldReturnAllUsers_AsDto()
        {
            //Pagination parameters
            var paginationParams = new PaginationParamsDto(1, 10);

            var data = new List<User>
            {
                new User { Id = 1, Username = "user1", IsActive = true, CreatedAt = DateTime.UtcNow.AddDays(-1) },
                new User { Id = 2, Username = "user2", IsActive = false, CreatedAt = DateTime.UtcNow }
            };
            var mockContext = CreateMockContext(data);
            var service = new AdminUsersService(mockContext.Object);
            var result = await service.GetAllUsersAsync(paginationParams);
            var resultList = result.Items.ToList();
            Assert.Equal(2, resultList.Count);
            Assert.Equal("user2", resultList[0].Username);
            Assert.False(resultList[0].IsActive);
        }

        //Check if GetUserByIdAsync returns user details when user exists
        [Fact]
        public async Task GetUserByIdAsync_ShouldReturnUserDetails_WhenUserExists()
        {
            var data = new List<User>
            {
                new User 
                { 
                    Id = 1, 
                    Username = "user1", 
                    IsActive = true, 
                    CreatedAt = DateTime.UtcNow.AddDays(-1), 
                    MyNotes = new List<Note>{new Note() }, 
                    Comments = new List<Comment>{ new Comment(), new Comment() }, 
                    Reactions = new List<NoteReaction>() 
                },
            };
            var mockContext = CreateMockContext(data);
            var service = new AdminUsersService(mockContext.Object);
            var result = await service.GetUserByIdAsync(1);
            Assert.True(result.Success);
            Assert.Equal("user1", result.Data!.Username);
            Assert.Equal(1, result.Data.TotalNotes);
            Assert.Equal(2, result.Data.TotalComments);
            Assert.Equal(0, result.Data.TotalReactions);

        }

        //Check if GetUserByIdAsync returns false when user does not exist
        [Fact]
        public async Task GetUserByIdAsync_ShouldReturnFalse_WhenUserDoesNotExist()
        {
            var data = new List<User>(); 
            var mockContext = CreateMockContext(data);
            var service = new AdminUsersService(mockContext.Object);

            var result = await service.GetUserByIdAsync(99);

            Assert.False(result.Success);
            Assert.Equal("User does not exist", result.Message);
        }


        //Check if BanUserAsync deactivates the user and removes tokens when user exists
        [Fact]
        public async Task BanUserAsync_ShouldDeactivateUserAndRemoveTokens_WhenValidUser()
        {
            //Create test data
            var refreshToken = new RefreshToken { Id = 1, UserId = 1 };
            var targetUser = new User
            {
                Id = 1,
                Role = "User",
                IsActive = true,
                RefreshTokens = new List<RefreshToken> { refreshToken }
            };

            var userData = new List<User> { targetUser };
            var tokensData = new List<RefreshToken> { refreshToken };

            var mockContext = CreateMockContext(userData, tokensData);
            var service = new AdminUsersService(mockContext.Object);

            //Try banning the user
            var result = await service.BanUserAsync(1);

            Assert.True(result.Success);

            //Flag must be changed to false
            Assert.False(targetUser.IsActive);

            //Verify that the refresh token was removed 
            mockContext.Verify(m => m.RefreshTokens.RemoveRange(It.IsAny<IEnumerable<RefreshToken>>()), Times.Once);
            mockContext.Verify(m => m.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
        }


        //Check if BanUserAsync returns false when user does not exist
        [Fact]
        public async Task BanUserAsync_ShouldReturnFalse_WhenUserDoesNotExist()
        {
            var data = new List<User>(); 
            var mockContext = CreateMockContext(data);
            var service = new AdminUsersService(mockContext.Object);

            //Try banning a non-existing user
            var result = await service.BanUserAsync(99);

            Assert.False(result.Success);
            Assert.Equal("User does not exist", result.Message);

            //Verify that no changes were made to the context
            mockContext.Verify(m => m.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Never);
        }


        [Fact]
        public async Task BanUserAsync_ShouldReturnFalse_WhenUserIsAdmin()
        {
            // Create test admin user
            var targetUser = new User { Id = 1, Role = "Admin", IsActive = true };

            var userData = new List<User> { targetUser };
            var mockContext = CreateMockContext(userData);
            var service = new AdminUsersService(mockContext.Object);

            //Try to ban admin user
            var result = await service.BanUserAsync(1);


            Assert.False(result.Success);
            Assert.Equal("You cannot ban another admin user", result.Message);
            Assert.True(targetUser.IsActive);

            //Check that no tokens were removed and no changes were saved
            mockContext.Verify(m => m.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Never);
        }
    }
}
