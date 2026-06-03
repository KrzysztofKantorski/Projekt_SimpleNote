using FluentValidation;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Projekt_SimpleNote.Data;
using Projekt_SimpleNote.Dto.Auth;
using Projekt_SimpleNote.Entities;
using System.Security.Cryptography;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Projekt_SimpleNote.Services.Interfaces;


namespace Projekt_SimpleNote.Services
{
    public class AuthService: IAuthService
    {
        //Add db context 
        private readonly ApplicationDbContext _context;

        //Validators
        private readonly IValidator<RegisterDto> _registerValidator;
        private readonly IValidator<LoginDto> _loginValidator;

        public AuthService(ApplicationDbContext context, IValidator<RegisterDto> registerValidator, IValidator<LoginDto> loginValidator)
        {
            _context = context;
            _registerValidator = registerValidator;
            _loginValidator = loginValidator;
        }

        public async Task<(bool Success, string Message)> LogoutAsync(string refreshToken)
        {
            if (refreshToken == null)
            {
                return (false, "Token expired");
            }

            //Find and Revoke refresh token
            var tokenEntity = await _context.RefreshTokens.FirstOrDefaultAsync(rf => rf.Token == refreshToken);

            if (tokenEntity == null) 
            {
                return (false, "Incorrect token");
            }

            //Check if token can be revoked
            if(tokenEntity != null && tokenEntity.RevokedAt == null)
            {
                tokenEntity.RevokedAt = DateTime.UtcNow;
                await _context.SaveChangesAsync();
            }

            return (true, "Logout successfull");

        }

        public async Task<(bool Success, string Message)> RegisterAsync(RegisterDto dto) {

            //Validate dto
            await _registerValidator.ValidateAndThrowAsync(dto);

            bool usernameInUse = await _context.Users.AnyAsync(u => u.Username == dto.Username);

            if (usernameInUse)
            {
                return (false, "Username alerdy in use");
            }

            var hashedPassword = BCrypt.Net.BCrypt.HashPassword(dto.Password);

            var newUser = new User
            {
                Username = dto.Username,
                PasswordHash = hashedPassword,
                Role = "User"
            };

            await _context.Users.AddAsync(newUser);
            await _context.SaveChangesAsync();

            return (true, "Registration went successfully.");
        }


      


        public async Task<(bool Success, string Message, TokenResponseDto? Tokens)> RefreshTokenAsync(string refreshToken) 
        {
            
            //validate token
            var existingToken = await _context.RefreshTokens
               .Include(u => u.User)
               .FirstOrDefaultAsync(rf => rf.Token == refreshToken);

            //Check if token is valid
            if (existingToken == null) 
            {
                return (false, "Incorrect token", null);
            }

            //Check if user got banned
            if (!existingToken.User.IsActive)
            {
                return (false, "Your account is not active.", null);
            }


            //Verify token
            if (existingToken.ExpiresAt < DateTime.UtcNow || existingToken.RevokedAt != null) {
                return (false, "Session expired. Log in again", null);
            }

            //Revoke token
            existingToken.RevokedAt = DateTime.UtcNow;

            //Create new access and refresh token
            var newAccessToken = GenerateJwtToken(existingToken.User);
            var newRefreshToken = GenerateRefreshToken();

            //Create new token object
            var newRefreshTokenEntity = new RefreshToken
            {
                Token = newRefreshToken,
                ExpiresAt = DateTime.UtcNow.AddDays(7),
                UserId = existingToken.UserId
            };

            //Save new token to db
            await _context.RefreshTokens.AddAsync(newRefreshTokenEntity);
            await _context.SaveChangesAsync();

            //Save data to dto
            var tokenDto = new TokenResponseDto(newAccessToken, newRefreshToken);

            return (true, "Session refreshed successfully", tokenDto);

        }


        public async Task<(bool Success, string Message, TokenResponseDto? Tokens)> LoginAsync (LoginDto dto)
        {
            await _loginValidator.ValidateAndThrowAsync(dto);

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Username == dto.Username);

            if (user == null)
            {
                return (false, "Incorrect username or password", null); 
            }

            if (!user.IsActive)
            {
                return (false, "Your account is not active.", null);
            }

            //Verify password
            bool isPasswordValid = BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash);

            if (!isPasswordValid) {
                return (false, "Incorrect username or password", null);
            }

            //Generate access token
            var accessToken = GenerateJwtToken(user);

            //Generate refresh token
            var refreshToken = GenerateRefreshToken();

            
            //Saving minimal info to token
            var refreshTokenEntity = new RefreshToken
            {
                Token = refreshToken,
                ExpiresAt = DateTime.UtcNow.AddDays(7),
                UserId = user.Id
            };

            //Save refresh token to db
            await _context.RefreshTokens.AddAsync(refreshTokenEntity);
            await _context.SaveChangesAsync();

            var tokenDto = new TokenResponseDto(accessToken, refreshToken);

            return (true, "Login successfull.", tokenDto);
        }

        private string GenerateJwtToken(User user) {
            //Dodanie claimów
            //Zaszyfrowanie

            var secretKey = Environment.GetEnvironmentVariable("JWT_SECRET")!;
            var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey));
            var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);

            //Add claims
            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim(ClaimTypes.Role, user.Role)
            };

            var token = new JwtSecurityToken(
                issuer: Environment.GetEnvironmentVariable("JWT_ISSUER"),
                audience: Environment.GetEnvironmentVariable("JWT_AUDIENCE"),
                claims: claims,
                expires: DateTime.UtcNow.AddMinutes(15), 
                signingCredentials: credentials
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }


        private string GenerateRefreshToken()
        {
            var randomNumber = new byte[32];
            using var rng = RandomNumberGenerator.Create();
            rng.GetBytes(randomNumber);
            return Convert.ToBase64String(randomNumber);
        }
    }
}
