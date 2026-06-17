import { Button, type ButtonProps } from '@mui/material';

export const AdminButton = ({ children, ...props }: ButtonProps) => {
  return (
    <Button
      fullWidth
      variant="contained"
      size="large"
      sx={{ mt: 3, mb: 2 }}
      {...props}
    >
      {children}
    </Button>
  );
};