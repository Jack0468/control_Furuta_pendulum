%% Week 10 - Furuta pendulum: state-feedback design by pole placement
% Converts the design requirements into pole locations, computes K, and
% evaluates each design on the linear model and on the nonlinear plant.
clear; clc; close all;
P = furuta_params();
[A, B, C, D] = furuta_linmodel(P);
figdir = fullfile('..', 'figures'); if ~exist(figdir, 'dir'), mkdir(figdir); end

%% 1. Requirements -> dominant poles
OS_max = 5;      % [%]  max overshoot of theta (2nd-order estimate)
Ts_max = 2.0;    % [s]  2% settling time of theta step
zeta = -log(OS_max/100)/sqrt(pi^2 + log(OS_max/100)^2);
sigma_min = 4/Ts_max;
fprintf('Requirement => zeta >= %.2f, zeta*wn >= %.2f rad/s\n', zeta, sigma_min);

%% 2. Candidate pole sets
zeta = 0.7;
designs = struct('name', {}, 'p', {});
wn = 4; pd = wn*(-zeta + 1i*sqrt(1 - zeta^2)*[1 -1]);
designs(end+1) = struct('name', 'D1 aggressive', 'p', [pd, -30, -40]);
designs(end+1) = struct('name', 'D2 moderate',   'p', [pd, -12, -15]);
wn = 3; pd = wn*(-zeta + 1i*sqrt(1 - zeta^2)*[1 -1]);
designs(end+1) = struct('name', 'D3 slow',       'p', [pd, -12, -15]);
% LQR for comparison
Q = diag([5 1 0 0]); R = 1;
Klqr = lqr(A, B, Q, R);

r_step = deg2rad(30);  alpha0 = deg2rad(10);
fprintf('\n%-14s %-38s %8s %8s %8s %8s %9s %9s\n', 'design', 'K', 'Tr[s]', 'Ts[s]', 'OS[%]', 'US[%]', '|u|10deg', '|u|step');
for k = 1:numel(designs) + 1
    if k <= numel(designs)
        K = place(A, B, designs(k).p); name = designs(k).name;
    else
        K = Klqr; name = 'LQR';
    end
    Acl = A - B*K;
    % reference tracking: u = -K(x - [r;0;0;0])  <=>  Nbar = K(1)
    sys_cl = ss(Acl, B*K(1), C, 0);
    S = stepinfo(sys_cl(1), 'SettlingTimeThreshold', 0.02);
    [y, tt] = step(sys_cl(1), 5);
    US = -min(y)/y(end)*100;
    u10 = abs(K*[0; alpha0; 0; 0]);
    ustep = abs(K(1)*r_step);
    fprintf('%-14s %-38s %8.2f %8.2f %8.1f %8.1f %9.1f %9.1f\n', name, mat2str(K, 3), ...
            S.RiseTime, S.SettlingTime, S.Overshoot, US, u10, ustep);
    designs_K{k} = K; names{k} = name; %#ok<SAGROW>
end

%% 3. Nonlinear evaluation of the chosen design (D2 by default)
K = designs_K{2};
% (a) recovery from alpha0 = 10 deg
[t1, x1, u1] = furuta_sim_cl(K, P, [0; alpha0; 0; 0], @(t) 0, 3);
% (b) 30 deg arm step
[t2, x2, u2] = furuta_sim_cl(K, P, zeros(4,1), @(t) r_step*(t >= 0.2), 4);
% (c) tap on the pendulum: 20 mN.m for 20 ms, plus constant arm drag 2 mN.m
op.tau_p = @(t) 0.02*(t >= 0.5 & t < 0.52);
op.tau_d = @(t) 0.002*(t >= 2);
[t3, x3, u3] = furuta_sim_cl(K, P, zeros(4,1), @(t) 0, 4, op);

figure('Position', [100 100 900 700]);
tests = {t1, x1, u1, '\alpha_0 = 10^\circ'; t2, x2, u2, '30^\circ arm step'; t3, x3, u3, 'tap + arm drag'};
for i = 1:3
    subplot(3,3,i);   plot(tests{i,1}, rad2deg(tests{i,2}(:,1))); grid on; ylabel('\theta [deg]'); title(tests{i,4});
    subplot(3,3,3+i); plot(tests{i,1}, rad2deg(tests{i,2}(:,2))); grid on; ylabel('\alpha [deg]');
    subplot(3,3,6+i); plot(tests{i,1}, tests{i,3}); grid on; ylabel('V_m [V]'); xlabel('t [s]');
    yline([P.Vmax -P.Vmax], 'r--');
end
exportgraphics(gcf, fullfile(figdir, 'w10_nonlinear_tests.png'));
fprintf('\nNonlinear (D2): max|u| = %.1f / %.1f / %.1f V; max|alpha| tap = %.1f deg; theta offset from drag = %.1f deg\n', ...
        max(abs(u1)), max(abs(u2)), max(abs(u3)), rad2deg(max(abs(x3(:,2)))), rad2deg(x3(end,1)));

%% 4. Largest recoverable initial angle (nonlinear + saturation), each design
fprintf('\nLargest recoverable alpha0 with |Vm| <= %g V:\n', P.Vmax);
for k = 1:numel(designs_K)
    amax = 0;
    for a0 = 2:1:40
        [~, x] = furuta_sim_cl(designs_K{k}, P, [0; deg2rad(a0); 0; 0], @(t) 0, 3);
        if abs(x(end,2)) < deg2rad(1) && max(abs(x(:,2))) < pi/2, amax = a0; else, break; end
    end
    fprintf('  %-14s %d deg\n', names{k}, amax);
end

%% 5. Robustness: nominal K on perturbed plants (+/-20%)
fprintf('\nRobustness of D2 (max real closed-loop pole, perturbed linear model):\n');
for nm = {'mp','Lp','Rm','km','Dr','Dp'}
    for s = [0.8 1.2]
        Pk = P; Pk.(nm{1}) = s*P.(nm{1}); Pk.Jp = Pk.mp*Pk.Lp^2/12;
        [Ak, Bk] = furuta_linmodel(Pk);
        fprintf('  %-3s x%.1f : %.2f\n', nm{1}, s, max(real(eig(Ak - Bk*K))));
    end
end

%% 6. Integral action on theta (rejects constant arm torque, R7)
% Augmented state xa = [x; xi], xi_dot = theta - r.  u = -[K Ki]*xa
Aa = [A zeros(4,1); 1 0 0 0 0];
Ba = [B; 0];
pa = [designs(2).p, -5];               % D2 poles + one integrator pole
Ka = place(Aa, Ba, pa);
fprintf('\nIntegral design Ka = %s\n', mat2str(Ka, 3));
% nonlinear simulation with the integrator state appended
tau_d = @(t) 0.002*(t >= 2); tau_p = @(t) 0.02*(t >= 0.5 & t < 0.52);
r = @(t) 0;
ctrl = @(t, z) min(max(-Ka*[z(1:4) - [r(t);0;0;0]; z(5)], -P.Vmax), P.Vmax);
f = @(t, z) [furuta_nl(z(1:4), ctrl(t, z), P, tau_d(t), tau_p(t)); z(1) - r(t)];
[ti, zi] = ode45(f, [0 6], zeros(5,1), odeset('RelTol',1e-6,'AbsTol',1e-8,'MaxStep',1e-3));
ui = arrayfun(@(k) ctrl(ti(k), zi(k,:).'), (1:numel(ti)).');
fprintf('Integral (nonlinear, tap + drag): final theta = %.2f deg, max|theta| = %.1f deg, max|alpha| = %.1f deg, max|u| = %.1f V\n', ...
        rad2deg(zi(end,1)), rad2deg(max(abs(zi(:,1)))), rad2deg(max(abs(zi(:,2)))), max(abs(ui)));
figure; subplot(3,1,1); plot(t3, rad2deg(x3(:,1)), ti, rad2deg(zi(:,1))); grid on; ylabel('\theta [deg]');
legend('D2 (no integrator)', 'D2 + integrator'); title('Pendulum tap at 0.5 s, constant arm drag from 2 s');
subplot(3,1,2); plot(t3, rad2deg(x3(:,2)), ti, rad2deg(zi(:,2))); grid on; ylabel('\alpha [deg]');
subplot(3,1,3); plot(t3, u3, ti, ui); grid on; ylabel('V_m [V]'); xlabel('t [s]');
exportgraphics(gcf, fullfile(figdir, 'w10_integral_action.png'));

%% 7. Figures: pole map (A2) and design comparison (A3)
figure; hold on; grid on;
plot(real(eig(A)), imag(eig(A)), 'kx', 'MarkerSize', 10, 'LineWidth', 1.5);
mk = {'o','s','d','^'};
for k = 1:numel(designs_K)
    pc = eig(A - B*designs_K{k});
    plot(real(pc), imag(pc), mk{k}, 'MarkerSize', 7, 'LineWidth', 1.2);
end
% requirement region: zeta >= 0.69 and zeta*wn >= 2
th = acos(0.69); rr = 50;
plot([0 -rr*cos(th)], [0 rr*sin(th)], 'k:', [0 -rr*cos(th)], [0 -rr*sin(th)], 'k:');
xline(-2, 'k--'); xline(0, 'k-');
xlim([-45 15]); ylim([-8 8]); xlabel('Re(s) [rad/s]'); ylabel('Im(s) [rad/s]');
legend(['open loop', names, {'\zeta = 0.69', '', '\zeta\omega_n = 2'}], 'Location', 'southwest');
title('Open-loop and closed-loop poles');
exportgraphics(gcf, fullfile(figdir, 'w10_pole_map.png'));

figure('Position', [100 100 800 600]);
tt = linspace(0, 4, 2001).';
for k = 1:numel(designs_K)
    Kk = designs_K{k};
    sys_x = ss(A - B*Kk, B*Kk(1), eye(4), 0);
    [x] = step(sys_x, tt) * r_step;
    u = (Kk(1)*r_step - x*Kk.');
    subplot(3,1,1); hold on; plot(tt, rad2deg(x(:,1)));
    subplot(3,1,2); hold on; plot(tt, rad2deg(x(:,2)));
    subplot(3,1,3); hold on; plot(tt, u);
end
subplot(3,1,1); grid on; ylabel('\theta [deg]'); title('30^\circ arm step, linear model');
yline(rad2deg(r_step)*[0.98 1.02], 'k:', 'HandleVisibility', 'off'); legend(names, 'Location', 'southeast');
subplot(3,1,2); grid on; ylabel('\alpha [deg]');
subplot(3,1,3); grid on; ylabel('V_m [V]'); xlabel('t [s]');
exportgraphics(gcf, fullfile(figdir, 'w10_design_comparison.png'));
