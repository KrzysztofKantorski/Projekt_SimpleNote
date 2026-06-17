import { createTheme } from '@mui/material/styles';

export const theme = createTheme({
  palette: {

    //Main color
    primary: {
      main: '#6A89A7',
      contrastText: '#fff',
    },

    //Accent
    secondary: {
      main: '#88BDF2',
    },

    //Background
    background: {
      default: '#BDDDFC', 
      paper: '#fff',   
    },
    
    //Text
    text: {
      primary: '#384959',
      secondary: '#6A89A7',
    },
  },

  //Border radius
  shape: {
    borderRadius: 8,
  },
  
  //Font
  typography: {
    fontFamily: '"Poppins", "Lato", "Helvetica", "Arial", sans-serif',
  },
});