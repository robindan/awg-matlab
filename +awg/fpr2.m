function F = fpr2(model, lambda, F0, varargin)
%   Propagates the field in the first free propagation region. The function
%   is called with the following syntax:
%
%   F = FPR1(AWG, lambda, F0) propagates the initial condition F0 to the
%   output plane of the first FPR. The propagation length is calculated
%   from the radius of curvature.
%
%   F = FPR1(__, NAME, VALUE) set options using one or more NAME, VALUE pairs
%   from the following set:
%   'Points'    - number of points to use when interpolating mode, the
%                 default is 100.
%
%   The return value is a general purpose Field object.

    import awg.*
    
    p = inputParser();
    addOptional(p, 'x', []);
    addParameter(p, 'Points', 250)
    parse(p, varargin{:})
    opts = p.Results;
    
    xi = F0.x;
    ui = F0.Ex; % TODO: add proper logic for selecting the correct field components!
    
    ns = model.getSlabWaveguide().index(lambda, 1);
    nc = model.getArrayWaveguide().index(lambda, 1);
    
    R = model.R;
    r = R / 2;
    if model.confocal
        r = R;
    end
    
    if isempty(opts.x)
        sf = linspace(-1/2,1/2,opts.Points)' * (model.No + 4) * max(model.do,model.wo);
    else
        sf = opts.x(:);
    end
    
    uf = 0;
%     for i = 1:model.N
%         
%         % intput cartesian coordinates
%         s0 = ((i - 1) - (model.N - 1)/2)*model.d;
%         t0 = s0 / R;
%         x0 = R * sin(t0);
%         z0 = R * (1 - cos(t0));
% 
%         % output cartesian coordinates
%         t = sf/r;
%         x = r * sin(t);
%         z = r * (1 + cos(t));
% 
%         % map output coordinates to local input
%         xf =  (x - x0) * cos(t0) + (z - z0) * sin(t0);
%         zf = -(x - x0) * sin(t0) + (z - z0) * cos(t0);
% 
%         % construct mode
%         xip = linspace(-1,1)*2*model.d;
%         F = model.getArrayAperture().mode(lambda,xip).normalize();
% 
%         % diffract in local cooridnates
%         u = diffract(lambda/ns,F.Ex*exp(-1i*2*pi/lambda*nc*i*model.dl),F.x,xf,zf);
%         
%         uf = uf + u;
%     end

%     % correct input phase curvature
%     a = x0 / model.R;
%     xp = model.R * tan(a);
%     dp = model.R * sec(a) - model.R;
%     up = u0 .* exp(+1i*2*pi/lambda*ns*dp);  % retarded phase
%     
% %     xp = x0;
% %     up = u0;
% 
%     % cartesian coordinates
%     a = s / r;
%     xf = r * sin(a);
%     zf = (model.defocus + model.R - r) + r * cos(a);
% 
%     % calculate diffraction
    xf = r * sin(sf/r);
    zf = r * (1 + cos(sf/r));
    uf = diffract(lambda/ns,ui,xi,xf,zf);
    
    % return normalized field
    F = Field(sf, uf).normalize(F0.power);
