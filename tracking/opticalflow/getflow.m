function framev = getflow(I1,I2)

% smoothness of flow
lambda = 50;

% warping parameters
pyramid_levels = 100; % as much as possible
pyramid_factor = 0.9;
warps = 1;
maxits = 15;

[flow ~] = ...
    coarse_to_fine(I1, I2, lambda, warps, maxits, pyramid_levels, pyramid_factor);

tmp = flow;

% Significant flow in x direction
tmp1logic = (tmp(:,:,1)<=-1)|(tmp(:,:,1)>=1);
tmpx = tmp1logic.*tmp(:,:,1);

% Significant flow in y direction
tmp2logic = (tmp(:,:,2)<=-1)|(tmp(:,:,2)>=1);
tmpy = tmp2logic.*tmp(:,:,2);

framev = zeros(size(tmp,1),size(tmp,2),2);
framev(:,:,1) = tmpx;
framev(:,:,2) = tmpy;


