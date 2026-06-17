import { api } from './axiosConfig';
import type { LoginDto, LoginResponse } from "../types/authTypes";


//Login admin
export const loginAdmin = async (data: LoginDto): Promise<LoginResponse> => {
  const response = await api.post<LoginResponse>('/auth/login', {
    username: data.username,
    password: data.password
  });
  return response.data;
};

//Logout
export const logoutAdmin = async () => {
  try {

    await api.post('/auth/logout', {});
  } 
  catch (error) {
  } 
  finally {
    localStorage.removeItem('token');
    localStorage.removeItem('isAuthenticated');
  }
};

