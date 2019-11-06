% First enter the fieldtrip directory and start running the defualt
% fieldtrip application using the ft_default call
cd /Users/davidmartin/Documents/GitHub/fieldtrip/
ft_defaults

% Next we would load the 3D Scan
cd /Users/davidmartin/Documents/GitHub/Structure.io-Dev/'Model Assets'/BlankMannequin
head_surface = ft_read_headshape('Model.obj');

% Convert units to mm
head_surface = ft_convert_units(head_surface, 'mm');

ft_plot_mesh(head_surface)

