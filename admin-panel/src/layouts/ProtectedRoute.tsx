import { Navigate, Outlet } from 'react-router-dom';

export const ProtectedRoute = () => {
    //Check if token exists
    const hasToken = !!localStorage.getItem('token');
    const isAuth = localStorage.getItem('isAuthenticated') === 'true';

    if (!isAuth || !hasToken) {
        console.log(' Redirect to login');
        return <Navigate to="/login" replace />;
    }

    return <Outlet />;
};