%% Week 9 - Furuta pendulum: LTI model and open-loop simulation
% Builds the linearised model, checks its properties, and compares the
% linear and nonlinear open-loop responses. Figures are saved to ../figures.
clear; clc; close all;
P = furuta_params();
[A, B, C, D] = furuta_linmodel(P);
sys = ss(A, B, C, D, 'StateName', {'theta','alpha','theta_dot','alpha_dot'}, ...
         'InputName', 'Vm', 'OutputName', {'theta','alpha'});
figdir = fullfile('..', 'figures'); if ~exist(figdir, 'dir'), mkdir(figdir); end

%% 1. Model properties
disp('A ='); disp(A); disp('B ='); disp(B);
p_ol = eig(A);
fprintf('Open-loop poles: %s\n', mat2str(p_ol.', 4));
fprintf('Reachability rank : %d of %d\n', rank(ctrb(A, B)), size(A, 1));
fprintf('Observability rank: %d of %d (theta and alpha)\n', rank(obsv(A, C)), size(A, 1));
fprintf('Observability rank: %d (theta only), %d (alpha only)\n', ...
        rank(obsv(A, C(1,:))), rank(obsv(A, C(2,:))));
z_theta = tzero(ss(A, B, C(1,:), 0));
fprintf('Zeros of theta/Vm: %s  (RHP zero => non-minimum phase)\n', mat2str(z_theta.', 4));
fprintf('Unstable time constant: %.0f ms\n', 1000/max(real(p_ol)));

%% 2. Open-loop release from a small angle: linear vs nonlinear
x0 = [0; deg2rad(2); 0; 0];
tf_ = 0.6; t = linspace(0, tf_, 601).';
[~, ~, xl] = initial(ss(A, B, eye(4), 0), x0, t);
[tn, xn] = ode45(@(t, x) furuta_nl(x, 0, P), [0 tf_], x0);
figure; plot(t, rad2deg(xl(:,2)), tn, rad2deg(xn(:,2)), '--'); grid on;
ylim([-10 200]); xlabel('t [s]'); ylabel('\alpha [deg]');
legend('linear', 'nonlinear'); title('Open loop, released at \alpha_0 = 2^\circ');
exportgraphics(gcf, fullfile(figdir, 'w9_openloop_release.png'));
idx = find(abs(xn(:,2)) > deg2rad(15), 1);
fprintf('Nonlinear: pendulum passes 15 deg after %.2f s\n', tn(idx));

%% 3. Voltage pulse input (1 V for 50 ms) from upright
u_pulse = @(t) 1.0*(t < 0.05);
[tn2, xn2] = ode45(@(t, x) furuta_nl(x, u_pulse(t), P), [0 0.5], zeros(4,1));
tl = linspace(0, 0.5, 501).'; ul = u_pulse(tl);
yl = lsim(sys, ul, tl);
figure; subplot(2,1,1); plot(tl, rad2deg(yl(:,1)), tn2, rad2deg(xn2(:,1)), '--'); grid on;
ylabel('\theta [deg]'); legend('linear','nonlinear'); title('1 V, 50 ms pulse');
subplot(2,1,2); plot(tl, rad2deg(yl(:,2)), tn2, rad2deg(xn2(:,2)), '--'); grid on;
ylim([-60 60]); ylabel('\alpha [deg]'); xlabel('t [s]');
exportgraphics(gcf, fullfile(figdir, 'w9_pulse_response.png'));

%% 4. Parameter uncertainty: how far does the unstable pole move?
fprintf('\nUnstable pole under +/-20%% parameter changes:\n');
names = {'mp','Lp','Lr','Rm','km','Dr','Dp'};
for k = 1:numel(names)
    for s = [0.8 1.2]
        Pk = P; Pk.(names{k}) = s*P.(names{k});
        Pk.Jp = Pk.mp*Pk.Lp^2/12;  Pk.Jr = Pk.mr*Pk.Lr^2/12;
        Ak = furuta_linmodel(Pk);
        fprintf('  %-3s x%.1f : %.2f rad/s\n', names{k}, s, max(real(eig(Ak))));
    end
end
