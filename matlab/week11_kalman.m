%% Week 11 - Steady-state Kalman filter as the observer (docs/09)
% Builds the discrete-time noise model (torque disturbances in, encoder quantisation
% out), computes the steady-state Kalman gain from the Riccati equation, and compares
% Kalman observers with the pole-placed observers on noise, disturbance response
% and robustness.
clear; clc; close all;
P = furuta_params();
D = furuta_design(P);
figdir = fullfile('..', 'figures'); if ~exist(figdir, 'dir'), mkdir(figdir); end
A = D.A; C = D.C; Ts = D.Ts;

%% 1. Noise model
% Process noise: torque disturbances w = [tau_d; tau_p] on the arm and pendulum.
% They enter the linear model through the inverse mass matrix at upright (doc 09, K3).
a = P.Jr + P.mp*P.Lr^2; b = 0.5*P.mp*P.Lp*P.Lr; c = P.Jp + 0.25*P.mp*P.Lp^2; Dl = a*c - b^2;
G = [0 0; 0 0; c/Dl b/Dl; b/Dl a/Dl];
sysG = c2d(ss(A, G, C, 0), Ts, 'zoh');   % w held over each sample, as in furuta_sim_obs
Gd = sysG.B;
sig_w = [2e-4; 5e-5];                     % torque noise std [N.m] used in validation V5
R = P.enc_sigma^2*eye(2);                 % quantisation noise, sigma = q/sqrt(12) (doc 08)
fprintf('G (continuous) =\n'); disp(G);
fprintf('R = %.3e * I2 (sigma_v = %.3f mrad)\n', R(1,1), 1e3*P.enc_sigma);

%% 2. Steady-state Kalman gain (predictor form) for a given process-noise scale
kalman_gain = @(s) kgain(D.Ad, C, Gd, diag((s*sig_w).^2), R);
[Lk, Pk] = kalman_gain(1);
fprintf('\nMatched Kalman gain (s = 1):\n'); disp(Lk);
fprintf('Kalman observer poles, s = log(z)/Ts: %s\n', mat2str(sort(log(eig(D.Ad - Lk*C))/Ts).', 4));
fprintf('Steady-state std of the prediction error: %s (theta, alpha in mrad; rates in mrad/s)\n', ...
        mat2str(1e3*sqrt(diag(Pk)).', 3));
% cross-check with MATLAB's kalman(): its L is the predictor-form gain for x[n+1|n]
[~, Lm] = kalman(ss(D.Ad, [D.Bd Gd], C, 0, Ts), diag(sig_w.^2), R);
fprintf('Check against kalman(): max|L - L_matlab| = %.2e\n', max(abs(Lk - Lm), [], 'all'));

%% 3. Compare observer families: Kalman (scaled Q) vs pole placement
scales = [0.3 1 10 100 1000 1e4];
pp = {[-15 -16 -17 -18], [-40 -45 -50 -55], [-100 -110 -120 -130], [-250 -260 -270 -280]};
cfg = struct('name', {}, 'L', {}, 'kind', {});
for s = scales
    cfg(end+1) = struct('name', sprintf('Kalman Q x%g', s^2), 'L', kalman_gain(s), 'kind', 'K'); %#ok<SAGROW>
end
for i = 1:numel(pp)
    Di = furuta_design(P, pp{i});
    cfg(end+1) = struct('name', sprintf('poles %d..%d', pp{i}(1), pp{i}(end)), 'L', Di.L, 'kind', 'P'); %#ok<SAGROW>
end

% 200 random +/-20% plants for a linear robustness count (sampled loop, nominal K and L)
names = {'mp','Lp','Lr','Rm','km','Dr','Dp','Jr'}; Nr = 200; rng(1);
F = 0.8 + 0.4*rand(Nr, numel(names));
plants = cell(Nr, 1);
for n = 1:Nr
    Pn = P; for j = 1:numel(names), Pn.(names{j}) = P.(names{j})*F(n,j); end
    Pn.Jp = Pn.mp*Pn.Lp^2/12;
    [An, Bn, Cn] = furuta_linmodel(Pn); plants{n} = c2d(ss(An, Bn, Cn, 0), Ts);
end

opN = struct('torque_std', sig_w);                                  % noise test (V5)
opT = struct('tau_p', @(t) 0.02*(t >= 0.5 & t < 0.52));             % tap test (V3)
fprintf('\n%-22s %16s %10s %12s %12s %10s %10s\n', 'observer', 'slowest pole', 'RMS u [V]', ...
        'RMS e_ad[d/s]', 'tap max|a|', 'max|u| tap', 'unstable');
M = zeros(numel(cfg), 5);
for i = 1:numel(cfg)
    L = cfg(i).L;
    sl = max(real(log(eig(D.Ad - L*C))/Ts));
    SN = furuta_sim_obs(P, D, zeros(4,1), 5, setfield(opN, 'L', L)); w = SN.t >= 1; %#ok<SFLD>
    ST = furuta_sim_obs(P, D, zeros(4,1), 3, setfield(opT, 'L', L));                %#ok<SFLD>
    nu = 0;
    for n = 1:Nr
        sk = plants{n};
        Acl = [sk.A, -sk.B*D.Ki, -sk.B*D.Kx; Ts*[1 0 0 0], 1, zeros(1,4); ...
               L*sk.C, -D.Bd*D.Ki, D.Ad - D.Bd*D.Kx - L*C];
        nu = nu + (max(abs(eig(Acl))) >= 1);
    end
    M(i,:) = [rms(SN.u(w)), rad2deg(rms(SN.e(w,4))), rad2deg(max(abs(ST.x(:,2)))), max(abs(ST.u)), nu];
    fprintf('%-22s %16.1f %10.3f %12.2f %12.1f %10.2f %7d/%d\n', cfg(i).name, sl, M(i,1:4), nu, Nr);
end

%% 4. Trade-off figure: noise vs disturbance response, coloured by robustness
% Only observers that survive the tap are plotted (the others fall, max|alpha| > 90 deg).
figure('Position', [100 100 760 480]); hold on;
isK = strcmp({cfg.kind}, 'K'); up = M(:,3) < 90;
plot(M(isK & up,1), M(isK & up,3), '-o', 'LineWidth', 1.4, 'MarkerSize', 7);
plot(M(~isK & up,1), M(~isK & up,3), '--s', 'LineWidth', 1.4, 'MarkerSize', 7);
short = [arrayfun(@(s) sprintf('K Q\\times%g', s^2), scales, 'UniformOutput', false), ...
         {'P -15', 'P -40', 'P -100', 'P -250'}];
for i = find(up).'
    dy = 0.35*(1 - 2*isK(i));                                 % Kalman labels below, poles above
    text(M(i,1), M(i,3) + dy, sprintf('%s [%d]', short{i}, M(i,5)), 'FontSize', 9, ...
         'HorizontalAlignment', 'center');
end
set(gca, 'XScale', 'log'); grid on; ylim([13 28]);
yline(15, 'r--', 'R6 limit 15^\circ', 'LabelHorizontalAlignment', 'left');
xlabel('RMS voltage caused by sensor + torque noise [V]  (lower = quieter)');
ylabel('max |\alpha| after 20 mN\cdotm tap [deg]');
legend('Kalman, increasing Q', 'pole placement', 'Location', 'northeast');
title('Observer trade-off  ([n] = unstable plants out of 200 with \pm20% parameters)');
exportgraphics(gcf, fullfile(figdir, 'w11_kalman_tradeoff.png'));

function [L, X] = kgain(Ad, C, Gd, Qw, R)
% Steady-state predictor-form Kalman gain from the filter Riccati equation (docs/09 K8-K9)
X = idare(Ad.', C.', Gd*Qw*Gd.', R);       % X = steady-state covariance of x[k|k-1]
L = Ad*X*C.'/(C*X*C.' + R);
end
