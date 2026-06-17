namespace Projekt_SimpleNote.Extensions
{
    public static class CorsExtension
    {
        public static IServiceCollection AddCorsConfiguration(this IServiceCollection services) {

            services.AddCors(options =>
            {
                options.AddPolicy("AdminPanelPolicy", 
                policy =>
                {
                    policy.WithOrigins(
                        "http://localhost:5173"
                    )
                    .AllowAnyHeader()
                    .AllowAnyMethod()
                    .AllowCredentials();
                });
            });
            return services;
        }
    }
}
