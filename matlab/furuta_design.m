function D = furuta_design(P, p_obs)
%FURUTA_DESIGN Final controller and observer gains, in one place.
%   D = furuta_design(P)          uses the default observer poles
%   D = furuta_design(P, p_obs)   uses the given continuous-time observer poles
%
%   Controller: D2 poles + integrator on theta (docs 04 and 06)
%       u = -Kx*xhat - Ki*xi,   xi_dot = theta_meas - r   (type-1 servo)
%   Observer (discrete, predictor form, runs at P.Ts):
%       xhat[k+1] = Ad*xhat[k] + Bd*u[k] + L*(y[k] - C*xhat[k])

if nargin < 2 || isempty(p_obs)
    % ~7-9x faster than the fastest controller pole (-15). Chosen over a slower
    % [-40..-55] set because the slower observer made 39/500 random +/-20% plants
    % unstable (6/500 with this set); its noise cost is small (RMS u ~0.09 V). See LOGBOOK 2026-10-29.
    p_obs = [-100 -110 -120 -130];
end

[A, B, C] = furuta_linmodel(P);
D.A = A; D.B = B; D.C = C; D.Ts = P.Ts;

% Controller poles (doc 03 section 3, doc 06)
zeta = 0.7; wn = 4;
pd = wn*(-zeta + 1i*sqrt(1 - zeta^2)*[1 -1]);
D.p_ctrl = [pd, -12, -15];
D.K = place(A, B, D.p_ctrl);              % state feedback without integrator (D2)

% Integral action: xa = [x; xi], xi_dot = theta - r
Aa = [A zeros(4,1); 1 0 0 0 0];
Ba = [B; 0];
D.p_int = [D.p_ctrl, -5];
Ka = place(Aa, Ba, D.p_int);
D.Kx = Ka(1:4); D.Ki = Ka(5);

% Discrete-time plant model for the observer (zero-order hold at Ts)
sysd = c2d(ss(A, B, C, 0), D.Ts, 'zoh');
D.Ad = sysd.A; D.Bd = sysd.B;

% Observer gain: place eig(Ad - L*C) at exp(p_obs*Ts)
D.p_obs = p_obs;
D.L = place(D.Ad', C', exp(p_obs*D.Ts)).';
end
