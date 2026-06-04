namespace Projekt_SimpleNote.Extensions
{
    public static class HttpContextExtension
    {
        public static long GetCurrentUserId(this HttpContext context)
        {
            if (context.Items["CurrentUserId"] is long userId)
            {
                return userId;
            }
            throw new UnauthorizedAccessException("Authorization error");
        }

        public static long? GetOptionalCurrentUserId(this HttpContext context)
        {
            if (context.Items["CurrentUserId"] is long userId)
            {
                return userId;
            }
            return null; // Zwraca null zamiast psuć aplikację
        }
    }
}
