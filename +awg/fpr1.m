function F = fpr1(model, lambda, F0, varargin)
%   Propagates the field in the first free propagation region. The function
%   is called with the following syntax:
%
%   F = FPR1(AWG, lambda, F0) propagates the initial condition F0 to the
%   output plane of the first FPR. The propagation length is calculated
%   from the radius of curvature.
%
%   F = FPR1(..., s) provide curvilinear output coordinate vector directly.
%
%   F = FPR1(__, NAME, VALUE) set options using one or more NAME, VALUE pairs
%   from the following set:
%   'Points'    - number of points to use when interpolating mode, the
%                 default is 100. this option is ignored is 's' is
%                 provided.
%
%   The return value is a general purpose Field object.

    import awg.*
    
    p = inputParser();
    addOptional(p, 'x', []);
    addParameter(p, 'Input', 0)
    addParameter(p, 'Points', 250)
    parse(p, varargin{:})
    opts = p.Results;
    
    xi = F0.x;
    ui = F0.Ex; % TODO: add proper logic for selecting the correct field components!
    
    % compute slab index
    ns = model.getSlabWaveguide().index(lambda, 1);
    
    % output curve coordinates
    if isempty(opts.x)
        sf = linspace(-1/2,1/2,opts.Points)' * (model.N + 4)*model.d;
    else
        sf = opts.x(:);
    end
    
    % radii of curvature
    R = model.R;
    r = model.R / 2;
    if model.confocal
        r = model.R;
    end
    
    % intput cartesian coordinates
    s0 = model.li + (opts.Input - (model.Ni - 1)/2)*max(model.di,model.wi);
    t0 = s0 / r;
    x0 = r * sin(t0);
    z0 = r * (1 - cos(t0));
    
    % output cartesian coordinates
    t = sf/R;
    x = R * sin(t);
    z = R * cos(t);
    
    % map output coordinates to local input
    a0 = atan(sin(t0) / (1 + cos(t0)));
    xf = (x + x0) * cos(a0) + (z + z0) * sin(a0);
    zf = -(x + x0) * sin(a0) + (z + z0) * cos(a0);
    
    % diffract in local cooridnates
    uf = diffract(lambda/ns,ui,xi,xf,zf);
    
%     % correct input phase curvature
%     a = s0 / r;
%     xp = r * tan(a);
%     dp = r * sec(a) - r;
%     up = u0 .* exp(+1i*2*pi/lambda*ns*dp);  % retard phase
% 
%     % cartesian coordinates
%     a = s / model.R;
%     xf = model.R * sin(a);
%     zf = model.defocus + model.R * cos(a);
% 
%     % calculate diffraction
%     u = diffract(lambda/ns,up,xp,xf,zf);
    
    % return normalized field
    F = Field(sf, uf).normalize(F0.power);
