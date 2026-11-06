%% Week 12 - Stability margins, stable gain ranges, linear vs nonlinear, published parameters
% Covers the rubric items not handled elsewhere: Bode/Nyquist margins, valid ranges of the
% controller parameters, closed-loop differences between the linear and nonlinear models,
% and sensitivity to the parameter values published for this hardware (docs/10).
clear; clc; close all;
P = furuta_params();
D = furuta_design(P);
Ts = D.Ts; Ad = D.Ad; Bd = D.Bd; C = D.C; L = D.L; Kx = D.Kx; Ki = D.Ki; Ct = [1 0 0 0];
deg = @rad2deg;

%% 1. Loop broken at the plant input (observer-based controller, sampled)
% Controller from y to u, with r = 0: states [xhat; xi], same update order as furuta_sim_obs
Ac = [Ad - Bd*Kx - L*C, -Bd*Ki; zeros(1,4), 1];
Bc = [L; Ts*[1 0]];
Cc = [-Kx, -Ki];
Ctrl = ss(Ac, Bc, Cc, zeros(1,2), Ts);
Plant = ss(Ad, Bd, C, zeros(2,1), Ts);
Lobs = -Ctrl*Plant;                                     % u_in -> u_out, closed loop = 1 + Lobs
% The same loop with the true state fed back, for comparison
Aad = [Ad zeros(4,1); Ts*Ct 1]; Bad = [Bd; 0];
Lsf = ss(Aad, Bad, [Kx Ki], 0, Ts);

fprintf('Open-loop poles of the loop outside the unit circle: %d (observer), %d (true state)\n', ...
        sum(abs(pole(Lobs)) > 1 + 1e-9), sum(abs(pole(Lsf)) > 1 + 1e-9));
for c = {Lobs, 'observer-based'; Lsf, 'true-state'}.'
    m = allmargin(c{1});
    fprintf('%-15s stable=%d | gain margins %s (%s dB) at %s rad/s | phase margins %s deg at %s rad/s | delay margin %.1f ms\n', ...
        c{2}, m.Stable, mat2str(m.GainMargin, 3), mat2str(20*log10(m.GainMargin), 3), mat2str(m.GMFrequency, 3), ...
        mat2str(m.PhaseMargin, 3), mat2str(m.PMFrequency, 3), 1e3*min([m.DelayMargin, inf])*Ts);
end

%% 2. Bode and Nyquist figure
w = logspace(-1, log10(pi/Ts), 3000);
H1 = squeeze(freqresp(Lobs, w)); H2 = squeeze(freqresp(Lsf, w));
figure('Position', [100 100 1000 420]);
subplot(2,2,1); semilogx(w, 20*log10(abs(H1)), w, 20*log10(abs(H2)), '--'); grid on;
ylabel('|L| [dB]'); yline(0, 'k:'); legend('observer-based', 'true state', 'Location', 'southwest'); xlim([w(1) w(end)]);
title('Loop broken at the plant input');
subplot(2,2,3); semilogx(w, rad2deg(unwrap(angle(H1))), w, rad2deg(unwrap(angle(H2))), '--'); grid on;
ylabel('phase [deg]'); xlabel('\omega [rad/s]'); xlim([w(1) w(end)]);
subplot(2,2,[2 4]); hold on;
plot(real(H1), imag(H1), real(H1), -imag(H1), 'Color', [0 0.45 0.74]);
plot(real(H2), imag(H2), '--', real(H2), -imag(H2), '--', 'Color', [0.85 0.33 0.1]);
plot(-1, 0, 'k+', 'MarkerSize', 10, 'LineWidth', 1.5);
th = linspace(0, 2*pi, 200); plot(-1 + 0.5*cos(th), 0.5*sin(th), 'k:');
axis equal; xlim([-4 2]); ylim([-3 3]); grid on; xlabel('Re L'); ylabel('Im L'); title('Nyquist (zoom near -1)');
furuta_savefig(gcf, 'w12_margins', 7.16, 2.4);

%% 3. Range of each controller parameter that keeps the sampled linear loop stable
rho = @(Kx_, Ki_, g) max(abs(eig([Ad, -g*Bd*Ki_, -g*Bd*Kx_; Ts*Ct, 1, zeros(1,4); ...
                                  L*C, -Bd*Ki_, Ad - Bd*Kx_ - L*C])));
grid_ = logspace(-4, log10(50), 6000);     % down to 1e-4 x nominal, so k_i's lower limit is found, not truncated
[~, i1] = min(abs(grid_ - 1));
names = {'k_theta', 'k_alpha', 'k_thetadot', 'k_alphadot', 'k_i', 'plant-input gain'};
fprintf('\nStable multiplier range, one parameter varied, others nominal (nominal = 1):\n');
for n = 1:6
    v = false(size(grid_));
    for i = 1:numel(grid_)
        K = [Kx Ki]; g = 1;
        if n <= 5, K(n) = K(n)*grid_(i); else, g = grid_(i); end
        v(i) = rho(K(1:4), K(5), g) < 1;
    end
    lo = NaN; hi = NaN;
    if v(i1)
        a = find(~v(1:i1), 1, 'last'); if isempty(a), lo = grid_(1); else, lo = grid_(a+1); end
        b = find(~v(i1:end), 1); if isempty(b), hi = grid_(end); else, hi = grid_(i1 + b - 2); end
    end
    if n <= 5, nom = [Kx Ki]; fprintf('  %-16s nominal %8.3f: x%.3f to x%.3f (%.3f to %.3f)\n', names{n}, nom(n), lo, hi, lo*nom(n), hi*nom(n));
    else, fprintf('  %-16s x%.3f to x%.3f\n', names{n}, lo, hi); end
end

%% 4. Observer: stability of the estimation error
z = eig(Ad - L*C);
fprintf('\nEstimation error e[k+1] = (Ad - L*C) e[k]: |z| = %s (all < 1), s = %s\n', mat2str(abs(z).', 4), mat2str(sort(log(z)/Ts).', 4));
fprintf('Ratio to the fastest controller pole (%.1f): %s\n', min(real(D.p_int)), mat2str(sort(abs(log(z)/Ts)/abs(min(real(D.p_int)))).', 3));

%% 5. Linear vs nonlinear closed loop (same K and L, no quantisation)
Acl = [Ad, -Bd*Ki, -Bd*Kx; Ts*Ct, 1, zeros(1,4); L*C, -Bd*Ki, Ad - Bd*Kx - L*C];
a0s = [5 10 20]; N = 3000; figure('Position', [100 100 1000 380]);
fprintf('\nLinear vs nonlinear, release from alpha0 (no quantisation, observer initialised from y):\n');
for j = 1:numel(a0s)
    x0 = [0; deg2rad(a0s(j)); 0; 0]; xh0 = [x0(1:2); 0; 0];
    S = furuta_sim_obs(P, D, x0, N*Ts, struct('quant', false, 'xhat0', xh0));
    zl = zeros(9, N); zl(:,1) = [x0; 0; xh0];
    for k = 1:N-1, zl(:,k+1) = Acl*zl(:,k); end
    ul = -[zeros(1,4), Ki, Kx]*zl;
    fprintf('  %2d deg: max|alpha| lin %.1f / nl %.1f deg; max|theta| lin %.1f / nl %.1f deg; max|u| lin %.2f / nl %.2f V (limit %g); RMS alpha diff %.3f deg\n', ...
        a0s(j), deg(max(abs(zl(2,:)))), deg(max(abs(S.x(:,2)))), deg(max(abs(zl(1,:)))), deg(max(abs(S.x(:,1)))), ...
        max(abs(ul)), max(abs(S.u)), P.Vmax, deg(rms(zl(2,:).' - S.x(:,2))));
    subplot(2, numel(a0s), j); plot(S.t, deg(zl(2,:)), S.t, deg(S.x(:,2)), '--'); grid on; xlim([0 2]);
    title(sprintf('\\alpha_0 = %d^\\circ', a0s(j))); if j == 1, ylabel('\alpha [deg]'); legend('linear', 'nonlinear'); end
    subplot(2, numel(a0s), numel(a0s) + j); plot(S.t, ul, S.t, S.u, '--'); grid on; xlim([0 2]); xlabel('t [s]');
    yline([P.Vmax -P.Vmax], 'r:'); if j == 1, ylabel('V_m [V]'); end
end
furuta_savefig(gcf, 'w12_linear_vs_nonlinear', 7.16, 2.3);

%% 6. Nominal design on plants with the parameter values published for this hardware (docs/10)
cases = {'J_r = m_r L_r^2/12', 'Jr', P.mr*P.Lr^2/12; 'D_r 0.0015, D_p 0.0005', 'D', [0.0015 0.0005]; ...
         'D_r 0.001, D_p 0.00005', 'D', [0.001 0.00005]};
x0 = [0; deg2rad(10); 0; 0]; tap = @(t) 0.02*(t >= 0.5 & t < 0.52);
fprintf('\nNominal controller and observer on plants with published parameter values:\n');
for c = 1:size(cases, 1)
    Pk = P;
    if strcmp(cases{c,2}, 'Jr'), Pk.Jr = cases{c,3}; else, Pk.Dr = cases{c,3}(1); Pk.Dp = cases{c,3}(2); end
    [Ak, Bk, Ck] = furuta_linmodel(Pk); sk = c2d(ss(Ak, Bk, Ck, 0), Ts);
    Ak_cl = [sk.A, -sk.B*Ki, -sk.B*Kx; Ts*Ct, 1, zeros(1,4); L*Ck, -Bd*Ki, Ad - Bd*Kx - L*C];
    S1 = furuta_sim_obs(P, D, x0, 4, struct('Pplant', Pk, 'xhat0', [P.enc_res*round(x0(1:2)/P.enc_res); 0; 0]));
    S3 = furuta_sim_obs(P, D, zeros(4,1), 4, struct('Pplant', Pk, 'tau_p', tap));
    fprintf('  %-24s linear max|z| %.4f | 10 deg: end |alpha| %.2f deg, max|u| %.1f V | tap: max|alpha| %.1f deg, max|u| %.1f V, RMS u (t>2) %.3f V\n', ...
        cases{c,1}, max(abs(eig(Ak_cl))), abs(deg(S1.x(end,2))), max(abs(S1.u)), deg(max(abs(S3.x(:,2)))), max(abs(S3.u)), rms(S3.u(S3.t > 2)));
end

%% 7. Motor current in the demanding tests (brief: DC motor voltage and current limits)
S1 = furuta_sim_obs(P, D, x0, 4, struct('xhat0', [P.enc_res*round(x0(1:2)/P.enc_res); 0; 0]));
S3 = furuta_sim_obs(P, D, zeros(4,1), 4, struct('tau_p', tap));
ipk = @(S) max(abs((S.u - P.km*S.x(:,3))/P.Rm));
fprintf('\nPeak motor current: 10 deg release %.2f A, tap %.2f A; stall current at 10 V = %.2f A\n', ipk(S1), ipk(S3), P.Vmax/P.Rm);
