function result = subsidence_model(p)
% SUBSIDENCE_MODEL
% Generalized modified influence-function model based on:
% Sheorey et al. (2000), Ground subsidence observations and a modified
% influence function method for complete subsidence prediction.
%
% Required fields:
%   H, W, L, drawDeg, NEW, h, e
%
% Optional:
%   x0, y0, dx, dy, mode, T, goafX0, goafY0, goafW, goafL
%
% Outputs:
%   Subsidence, horizontal displacement, slope and numerical strain.

    % -------------------- defaults --------------------
    if ~isfield(p,'x0'), p.x0 = 100; end
    if ~isfield(p,'y0'), p.y0 = 100; end
    if ~isfield(p,'dx'), p.dx = 4; end
    if ~isfield(p,'dy'), p.dy = 5; end
    if ~isfield(p,'mode'), p.mode = "Single Seam"; end
    if ~isfield(p,'T'), p.T = 0; end
    if ~isfield(p,'goafX0'), p.goafX0 = p.x0; end
    if ~isfield(p,'goafY0'), p.goafY0 = p.y0; end
    if ~isfield(p,'goafW'), p.goafW = p.W; end
    if ~isfield(p,'goafL'), p.goafL = p.L; end

    % -------------------- validation --------------------
    if p.H <= 0 || p.W <= 0 || p.L <= 0 || p.NEW <= 0 || ...
            p.h <= 0 || p.e <= 0 || p.drawDeg <= 0
        error('H, W, L, NEW, h, e and draw angle must be positive.');
    end

    if p.e > 1
        error('Extraction factor e must be between 0 and 1.');
    end

    if p.drawDeg >= 90
        error('Draw angle must be less than 90 degrees.');
    end

    if strcmpi(string(p.mode),"Multi-seam")
        if p.T < 0 || p.T >= p.H
            error('For multi-seam mode, 0 <= T < H is required.');
        end
    end

    % -------------------- panel geometry --------------------
    panelX = [p.x0, p.x0+p.W, p.x0+p.W, p.x0];
    panelY = [p.y0, p.y0, p.y0+p.L, p.y0+p.L];

    x_co = [panelX, panelX(1)];
    y_co = [panelY, panelY(1)];

    % Influence radius R = H*tan(gamma)
    R = p.H*tand(p.drawDeg);

    % Surface grid extends beyond the panel by approximately one influence radius.
    xmin = max(0, floor((p.x0 - R)/p.dx)*p.dx);
    xmax = ceil((p.x0+p.W + R)/p.dx)*p.dx;
    ymin = max(0, floor((p.y0 - R)/p.dy)*p.dy);
    ymax = ceil((p.y0+p.L + R)/p.dy)*p.dy;

    [X,Y] = meshgrid(xmin:p.dx:xmax, ymin:p.dy:ymax);

    % -------------------- Sheorey ring weights --------------------
    % 10 rings x 64 equal sectors.
    % Ring weights reported in the paper; their sum is 1.0.
    ringWeights = [ ...
        0.0297, 0.0854, 0.1311, 0.1607, 0.1708, ...
        0.1596, 0.1294, 0.0859, 0.0397, 0.0069];

    nRings = 10;
    nSectors = 64;
    sectorWeights = ringWeights / nSectors;

    % -------------------- empirical subsidence factor --------------------
    widthRatio = p.W/(p.H*p.NEW);

    if strcmpi(string(p.mode),"Single Seam")
        % Sheorey et al. Eq. (3)
        baseFactor = 0.33 * ...
            (1 + 1.1*tanh(1.4*(widthRatio - 1.8)));
    else
        % Sheorey et al. Eq. (4), approximate multi-seam relation
        baseFactor = 0.12 * ...
            (1 + 5.9*tanh(0.38*(widthRatio - 1.45)));
    end

    % Numerical safeguard for very small/non-effective widths.
    baseFactor = max(baseFactor,0);

    % Maximum possible subsidence; negative sign is used for downward movement.
    Smax = baseFactor*p.h*p.e;

    % -------------------- output arrays --------------------
    Subsidence = zeros(size(X));
    Ux = zeros(size(X));
    Uy = zeros(size(X));

    % Sector centroid locations
    dr = R/nRings;
    rho = ((1:nRings)-0.5)*dr;
    theta = ((1:nSectors)-0.5)*(2*pi/nSectors);

    % -------------------- influence-function summation --------------------
    for m = 1:size(X,1)
        for n = 1:size(X,2)

            Px = X(m,n);
            Py = Y(m,n);

            Sz = 0;
            Sx = 0;
            Sy = 0;

            for i = 1:nRings

                xel = Px + rho(i)*cos(theta);
                yel = Py + rho(i)*sin(theta);

                inside = inpolygon(xel,yel,panelX,panelY);

                if ~any(inside)
                    continue;
                end

                xx = xel(inside);
                yy = yel(inside);

                sw = sectorWeights(i);

                % Distance from extraction element to nearest panel boundary.
                db = min([ ...
                    xx - p.x0, ...
                    p.x0+p.W - xx, ...
                    yy - p.y0, ...
                    p.y0+p.L - yy],[],2);

                % d = distance from starting face.
                % dmax = distance between starting and ending face lines.
                d = yy - p.y0;
                dmax = p.L;

                % Default local values
                localNEW = p.NEW*ones(size(xx));
                localSmax = Smax*ones(size(xx));

                % ---------------- multi-seam / goaf correction ----------------
                if strcmpi(string(p.mode),"Multi-seam")

                    inGoaf = xx >= p.goafX0 & ...
                             xx <= p.goafX0+p.goafW & ...
                             yy >= p.goafY0 & ...
                             yy <= p.goafY0+p.goafL;

                    if any(inGoaf)
                        % Sheorey et al. Eq. (10)
                        localNEW(inGoaf) = ...
                            (0.6*p.NEW*(p.H-p.T) + p.NEW*p.T)/p.H;

                        % Approximately 17% increase in subsidence factor
                        % for elements influenced by overlying goaf.
                        localSmax(inGoaf) = ...
                            1.17*baseFactor*p.h*p.e;
                    end
                end

                % ---------------- edge correction Wz ----------------
                % Sheorey et al. Eq. (8)
                Wz = 0.5*tanh( ...
                    (5*db)./(1.5*localNEW*p.h) - 2.4) + 0.5;

                % ---------------- asymmetry correction Qz ----------------
                % Sheorey et al. Eq. (9)
                Qz = 0.9 - 0.1*tanh( ...
                    0.5*(d - 0.4*dmax));

                % Vertical contribution: negative = downward subsidence.
                dVz = -sw*localSmax.*Wz.*Qz;

                Sz = Sz + sum(dVz);

                % ---------------- horizontal displacement ----------------
                % From Fig. 10:
                % dVxy = tan(z)dVz, where tan(z)=horizontal_distance/H.
                dxEl = xx - Px;
                dyEl = yy - Py;

                dVx = dVz .* dxEl / p.H;
                dVy = dVz .* dyEl / p.H;

                Sx = Sx + sum(dVx);
                Sy = Sy + sum(dVy);
            end

            Subsidence(m,n) = Sz;
            Ux(m,n) = Sx;
            Uy(m,n) = Sy;
        end
    end

    % -------------------- slope --------------------
    [dSdy,dSdx] = gradient(Subsidence,p.dy,p.dx);

    slopeX = dSdx;
    slopeY = dSdy;
    slopeMagnitude = sqrt(slopeX.^2 + slopeY.^2);

    % -------------------- numerical strain --------------------
    % These are calculated from the horizontal displacement field.
    % The paper also gives empirical K1/K2/K3 relations, but their
    % constants are case/measurement dependent and are therefore not
    % invented here.
    [dUxdy,dUxdx] = gradient(Ux,p.dy,p.dx);
    [dUydy,dUydx] = gradient(Uy,p.dy,p.dx);

    Exx = dUxdx;
    Eyy = dUydy;
    Exy = 0.5*(dUxdy + dUydx);

    meanStrain = 0.5*(Exx + Eyy);
    radiusStrain = sqrt(((Exx-Eyy)/2).^2 + Exy.^2);

    principal1 = meanStrain + radiusStrain;
    principal2 = meanStrain - radiusStrain;

    maxTensileStrain = max(principal1(:));
    maxCompressiveStrain = min(principal2(:));

    % -------------------- width classification --------------------
    if widthRatio < 1
        widthClass = 'Non-effective';
    elseif widthRatio < 3.5
        widthClass = 'Sub-critical';
    else
        widthClass = 'Super-critical';
    end

    % -------------------- package results --------------------
    result.X = X;
    result.Y = Y;
    result.Subsidence = Subsidence;

    result.Ux = Ux;
    result.Uy = Uy;

    result.slopeX = slopeX;
    result.slopeY = slopeY;
    result.slopeMagnitude = slopeMagnitude;

    result.Exx = Exx;
    result.Eyy = Eyy;
    result.Exy = Exy;

    result.principal1 = principal1;
    result.principal2 = principal2;

    result.maxTensileStrain = maxTensileStrain;
    result.maxCompressiveStrain = maxCompressiveStrain;

    result.R = R;
    result.widthRatio = widthRatio;
    result.widthClass = widthClass;
    result.baseFactor = baseFactor;
    result.Smax = Smax;

    result.panelX = panelX;
    result.panelY = panelY;
    result.x_co = x_co;
    result.y_co = y_co;

    result.ringWeights = ringWeights;
    result.nRings = nRings;
    result.nSectors = nSectors;

    result.dx = p.dx;
    result.dy = p.dy;
end
