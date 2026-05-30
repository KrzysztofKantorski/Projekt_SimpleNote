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

            //Check if endpoint enables anonymous users to access
            if (endpoint?.Metadata.GetMetadata<IAllowAnonymous>() != null)
            {
                await _next(context);
                return;
            }

            //If request requires user authentication
            if (context.User.Identity?.IsAuthenticated == true)
            {
                var userIdClaim = context.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

                if (long.TryParse(userIdClaim, out long userId))
                {
                    //Get isActive flag from db
                    var userStatus = await dbContext.Users
                        .Where(u => u.Id == userId)
                        .Select(u => new { u.IsActive })
                        .FirstOrDefaultAsync();

                    //Check if user account is active
                    if (userStatus == null || !userStatus.IsActive)
                    {
                        context.Response.StatusCode = StatusCodes.Status403Forbidden;
                        context.Response.ContentType = "application/json";
                        await context.Response.WriteAsJsonAsync(new { message = "Your account is not active." });
                        return;
                    }

                    // Save userId for controllers
                    context.Items["CurrentUserId"] = userId;
                }
            }

            await _next(context);
        }
    }
}