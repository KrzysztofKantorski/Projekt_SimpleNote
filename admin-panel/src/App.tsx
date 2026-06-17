import { createBrowserRouter, RouterProvider } from 'react-router-dom';
import { AdminLayout } from './layouts/AdminLayout';
import { Dashboard } from './pages/Dashboard';
import { UserList } from './pages/UserList';
import { UserDetails } from './pages/UserDetails';

import { Login } from './pages/Login';
import {ProtectedRoute} from './layouts/ProtectedRoute';

import {SubjectList} from './pages/SubjectList';
import {ReactionList} from  './pages/ReactionList';
import {CommentList} from './pages/CommentList';
const router = createBrowserRouter([
  //Public routes
  {
    path: '/login',
    element: <Login />,
  },
  //Protected routes
  {
    element: <ProtectedRoute />, 
    children: 
      [
        {
          path: '/',
            element: <AdminLayout />, 
            children: [
              {
                index: true,
                element: <Dashboard />,
              },
              {
                path: 'users',
                element: <UserList />,
              },
              {
                path: 'users/:id',
                element: <UserDetails />,
              },
              {
                path: 'subjects',
                element: <SubjectList />,
              },
              {
                path: 'reactions',
                element: <ReactionList />,
              },
               {
                path: 'comments',
                element: <CommentList />,
              },
            ],
        }
      ],
  },
]);

export const App = () => {
  return <RouterProvider router={router} />;
};