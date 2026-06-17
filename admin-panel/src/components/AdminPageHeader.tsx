import { Box, Typography, Button } from '@mui/material';


interface AdminPageHeaderProps {
  title: string;
  actionText?: string;
  onAction?: () => void;
}

export const AdminPageHeader = ({ title, actionText, onAction }: AdminPageHeaderProps) => {
  return (
    <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 4 }}>
      <Typography variant="h4" color="text.primary">
        {title}
      </Typography>
      {actionText && onAction && (
        <Button 
          variant="contained" 
          onClick={onAction}
        >
          {actionText}
        </Button>
      )}
    </Box>
  );
};