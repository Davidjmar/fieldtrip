function test_headmodel_concentricspheres_new_old

% MEM 1500mb
% WALLTIME 00:10:00

% generate a unit sphere
[pnt, tri] = mesh_sphere(162);

% create the BEM geometries
geom = [];
geom.bnd(1).pnt = pnt * 100;
geom.bnd(1).tri = tri;
geom.bnd(2).pnt = pnt * 90;
geom.bnd(2).tri = tri;
geom.bnd(3).pnt = pnt * 80;
geom.bnd(3).tri = tri;

elec.chanpos = pnt * 100;
elec.elecpos = pnt * 100;
for i=1:size(pnt,1)
  elec.label{i} = sprintf('%d', i);
end

arg(1).name = 'conductivity';
arg(1).value = {[1 1/20 1], [0.33 0.125 0.33], [1 1 1], [0.1 0.1 0.1]};

optarg = constructalloptions(arg);
% random shuffle the configurations
% optarg = optarg(randperm(size(optarg,1)), :);

for i=1:size(optarg,1)
  
  vol = {};
  arg = optarg(i,:);
  
  % new way - low level:
  vol{1} = ft_headmodel_concentricspheres(geom.bnd,arg{:});

  % old way:
  tmpcfg = ft_keyval2cfg(arg{:});
  tmpcfg.headshape = geom.bnd;
  vol{2} = ft_prepare_concentricspheres(tmpcfg);
  vol{2} = rmfield(vol{2},'unit');
  
  % new way - high level:
  tmpcfg = ft_keyval2cfg(arg{:});
  tmpcfg.method = 'concentricspheres';
  vol{3} = ft_prepare_headmodel(tmpcfg,geom.bnd);
  vol{3} = rmfield(vol{3},'unit');
  
  % old way, one sphere:
  tmpcfg = ft_keyval2cfg(arg{:});
  tmpcfg.headshape = geom.bnd;
  vol{4} = ft_prepare_concentricspheres(tmpcfg);
  vol{4} = rmfield(vol{4},'unit');
  
  % new way - high level, one sphere:
  tmpcfg = ft_keyval2cfg(arg{:});
  tmpcfg.method = 'concentricspheres';
  vol{5} = ft_prepare_headmodel(tmpcfg,geom.bnd);
  vol{5} = rmfield(vol{5},'unit');
  
  % compute the leadfields for a comparison
  [vol{1}, elec] = ft_prepare_vol_sens(vol{1}, elec);
  [vol{2}, elec] = ft_prepare_vol_sens(vol{2}, elec);
  [vol{3}, elec] = ft_prepare_vol_sens(vol{3}, elec);
  [vol{4}, elec] = ft_prepare_vol_sens(vol{4}, elec);
  [vol{5}, elec] = ft_prepare_vol_sens(vol{5}, elec);
  lf{1} = ft_compute_leadfield([0 10 60], elec, vol{1});
  lf{2} = ft_compute_leadfield([0 10 60], elec, vol{2});
  lf{3} = ft_compute_leadfield([0 10 60], elec, vol{3});
  lf{4} = ft_compute_leadfield([0 10 60], elec, vol{4});
  lf{5} = ft_compute_leadfield([0 10 60], elec, vol{5});
  
  % compare the volume conductor structures
  comb = nchoosek(1:numel(vol),2);
  for j=1:size(comb,1)
    chk = comb(j,:);
    err = norm(lf{chk(1)} - lf{chk(2)}) / norm(lf{chk(1)});
    if err>0.001
      error('combination %d %d not successful\n',chk(1),chk(2));
    end
  end

end
