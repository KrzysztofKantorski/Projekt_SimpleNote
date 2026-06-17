import { TextField, type TextFieldProps } from '@mui/material';

export const AdminInput = (props: TextFieldProps) => {
  return (
    <TextField
      fullWidth
      margin="normal" 
      {...props}      
    />
  );
};