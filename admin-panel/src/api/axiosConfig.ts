import axios, { AxiosError, type InternalAxiosRequestConfig } from 'axios';

// Basic axios config
export const api = axios.create({
  baseURL: 'http://localhost:5168/api', 
  withCredentials: true,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Queue for token refresh
let isRefreshing = false;
let failedQueue: Array<{ 
  resolve: (value?: unknown) => void; 
  reject: (reason?: any) => void 
}> = [];

const processQueue = (error: Error | null, token: string | null = null) => {
  failedQueue.forEach((prom) => {
    if (error) prom.reject(error);
    else prom.resolve(token);
  });
  failedQueue = [];
};

// Interceptor - add JWT to header
api.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const token = localStorage.getItem('token');
    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Interceptor - when access token ended, try refreshing
api.interceptors.response.use(
  (response) => {
    if (response.status === 204) {
      response.data = {};
    }
    return response;
  },
  async (error: AxiosError) => {
    // Get previous request
    const originalRequest = error.config as InternalAxiosRequestConfig & { _retry?: boolean };

    //Only if error has 401 status code and it is not login 
    if (error.response?.status === 401 && !originalRequest._retry && !originalRequest.url?.includes('/auth/login')) {
      
      if (isRefreshing) {
        return new Promise(function (resolve, reject) {
          failedQueue.push({ resolve, reject });
        })
          .then((token) => {
            if (originalRequest.headers) originalRequest.headers.Authorization = `Bearer ${token}`;
            return api(originalRequest); 
          })
          .catch((err) => Promise.reject(err));
      }

      originalRequest._retry = true;
      isRefreshing = true;

      try {
        //Send request for token refresh
        const response = await axios.post('http://localhost:5168/api/auth/refresh', {}, {
          withCredentials: true 
        });

        const newAccessToken = response.data.tokens.accessToken;
        
        // Save token
        localStorage.setItem('token', newAccessToken);
        localStorage.setItem('isAuthenticated', 'true'); 

        if (originalRequest.headers) {
          originalRequest.headers.Authorization = `Bearer ${newAccessToken}`;
        }

        // Go to next requests
        processQueue(null, newAccessToken);
        
        return api(originalRequest);

      } catch (refreshError) {
        // Refresh request returned error
        processQueue(refreshError as Error, null);
        localStorage.removeItem('token');
        localStorage.removeItem('isAuthenticated');
        
        if (!window.location.pathname.includes('/login')) {
          window.location.href = '/login';
        }
        return Promise.reject(new Error('Sesja wygasła. Zaloguj się ponownie.'));
      } finally {
        isRefreshing = false;
      }
    }

    if (error.response?.status === 403) {
      localStorage.removeItem('token');
      localStorage.removeItem('isAuthenticated');
      if (!window.location.pathname.includes('/login')) {
        window.location.href = '/login';
      }
      return Promise.reject(new Error('Odmowa dostępu. Nie masz uprawnień do tego zasobu.'));
    }
    
    const errorMessage = error.response?.data 
      // @ts-ignore - bezpieczny fallback jeśli backend nie zwróci obiektu z polem message
      ? error.response.data.message 
      : `Błąd HTTP: ${error.response?.status}`;
      
    return Promise.reject(new Error(errorMessage));
  }
);