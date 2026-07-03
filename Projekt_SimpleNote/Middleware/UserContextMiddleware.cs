using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using Projekt_SimpleNote.Data;
using System.Security.Claims;

namespace Projekt_SimpleNote.Middleware
{
    public class UserContextMiddleware
    {
        private readonly RequestDelegate _next;

        public UserContextMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task InvokeAsync(HttpContext context, ApplicationDbContext dbContext)
        {
            var endpoint = context.GetEndpoint();

            if (endpoint?.Metadata.GetMetadata<IAllowAnonymous>() != null)
            {
                await _next(context);
                return;
            }

            // If endpoint uses [Authorize]
            if (context.User.Identity?.IsAuthenticated == true)
            {
                // Get id from jwt
                var userIdClaim = context.User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                                  ?? context.User.FindFirst("sub")?.Value;

                if (long.TryParse(userIdClaim, out long userId))
                {
                    // Get isActive flag
                    var userStatus = await dbContext.Users
                        .Where(u => u.Id == userId)
                        .Select(u => new { u.IsActive })
                        .FirstOrDefaultAsync();

                    // If user is banned or does not exist
                    if (userStatus == null || !userStatus.IsActive)
                    {
                        context.Response.StatusCode = StatusCodes.Status403Forbidden;
                        context.Response.ContentType = "application/json";
                        await context.Response.WriteAsJsonAsync(new { message = "Your account is not active." });
                        return; 
                    }

                    // Save user Id
                    context.Items["CurrentUserId"] = userId;
                }
                else
                {
                    
                    context.Response.StatusCode = StatusCodes.Status401Unauthorized;
                    context.Response.ContentType = "application/json";
                    await context.Response.WriteAsJsonAsync(new { message = "Malformed token: User ID could not be resolved." });
                    return;
                }
            }

            await _next(context);
        }
    }
}