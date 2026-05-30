using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using FluentValidation;
namespace Projekt_SimpleNote.Middleware
{
    public class GlobalExceptionHandler: IExceptionHandler
    {
        private readonly ILogger<GlobalExceptionHandler> _logger;

        public GlobalExceptionHandler(ILogger<GlobalExceptionHandler> logger)
        {
            _logger = logger;
        }


        public async ValueTask<bool> TryHandleAsync(
            HttpContext httpContext,
            Exception exception,
            CancellationToken cancellationToken)
        {
            _logger.LogError(exception, "Error captured: {Message}", exception.Message);


            //Errors from fluent validation
            if (exception is ValidationException validationException)
            {
                httpContext.Response.StatusCode = StatusCodes.Status400BadRequest;

                var errors = validationException.Errors
                    .GroupBy(x => x.PropertyName)
                    .ToDictionary(
                        g => g.Key,
                        g => g.Select(x => x.ErrorMessage).ToArray()
                    );

                var validationProblemDetails = new ValidationProblemDetails(errors)
                {
                    Status = StatusCodes.Status400BadRequest,
                    Title = "Validation Failed",
                    Detail = "One or more validation errors occurred."
                };

                await httpContext.Response.WriteAsJsonAsync(validationProblemDetails, cancellationToken);
                return true;
            }


            //Exception handling
            var (statusCode, title, detail) = exception switch
            {
                UnauthorizedAccessException =>
                    (
                        StatusCodes.Status403Forbidden, 
                        "Forbidden", 
                        "You do not have permission to access this resource."
                    ),
                
                KeyNotFoundException =>
                    (
                        StatusCodes.Status404NotFound, 
                        "Not Found", 
                        "The requested resource was not found."
                    ),

                InvalidOperationException =>
                    (
                        StatusCodes.Status409Conflict, 
                        "Conflict", 
                        exception.Message
                    ),

                // Default - 500
                _ =>
                    (
                        StatusCodes.Status500InternalServerError, 
                        "Internal Server Error", 
                        "An unexpected error occurred."
                    )
            };


            httpContext.Response.StatusCode = statusCode;

            var problemDetails = new ProblemDetails
            {
                Status = statusCode,
                Title = title,
                Detail = detail 
            };

            await httpContext.Response.WriteAsJsonAsync(problemDetails, cancellationToken);

            return true;
        }
    }
}
