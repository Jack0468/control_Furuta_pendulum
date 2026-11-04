%% build_furuta_loop.m
% Builds the full-state-feedback loop for the Furuta pendulum in Simulink:
%
%   [Furuta plant] -> [-K] -> [Saturation] -> (+ tap) -> back into plant
%         |                        |
%         +-> [Demux] -> alpha -> [180/pi] -> [Mux] -> [Scope]
%                                   u -------->
%
% Run your design script FIRST so A, B and K (the 1x4 controller gain from
% place) are in the workspace, then run this script.

%% Check the workspace
if ~exist('A','var') || ~exist('B','var') || ~exist('K','var')
    error('Run your design script first so A, B and K are in the workspace.');
end
if ~isequal(size(K), [1 4])
    error(['K is %dx%d, but it should be the 1x4 controller gain from place(A,B,p). ' ...
           'If your stiffness matrix is also called K, rename it (e.g. Ks).'], ...
           size(K,1), size(K,2));
end

%% Settings (edit these)
x0       = [0; deg2rad(10); 0; 0];  % start with the pendulum tilted 10 deg
Vmax     = 10;                      % motor voltage limit (V)
tap_amp  = 1;                       % size of the tap (V)
tap_time = 2;                       % when the tap happens (s)
tap_len  = 0.1;                     % how long the tap lasts (s)

%% Create a fresh model
mdl = 'furuta_loop';
if bdIsLoaded(mdl), close_system(mdl, 0); end
if exist([mdl '.slx'], 'file'), delete([mdl '.slx']); end
new_system(mdl);
open_system(mdl);
set_param(mdl, 'StopTime', '4', 'Solver', 'ode45', 'MaxStep', '1e-3');

%% 1. Plant: State-Space block (motor + arm + pendulum)
add_block('simulink/Continuous/State-Space', [mdl '/Furuta plant'], ...
    'A', 'A', 'B', 'B', 'C', 'eye(4)', 'D', 'zeros(4,1)', ...
    'Position', [380 100 480 160]);
try
    set_param([mdl '/Furuta plant'], 'InitialCondition', 'x0');
catch
    set_param([mdl '/Furuta plant'], 'X0', 'x0');   % older MATLAB releases
end

%% 2. Controller: Gain -K
add_block('simulink/Math Operations/Gain', [mdl '/Controller -K'], ...
    'Gain', '-K', 'Multiplication', 'Matrix(K*u)', ...
    'Position', [540 110 600 150]);

%% 3. Saturation: +/- Vmax
add_block('simulink/Discontinuities/Saturation', [mdl '/Saturation'], ...
    'UpperLimit', 'Vmax', 'LowerLimit', '-Vmax', ...
    'Position', [640 110 680 150]);

%% Tap disturbance: a short voltage pulse (step on, then step off)
add_block('simulink/Sources/Step', [mdl '/Tap on'], ...
    'Time', 'tap_time', 'Before', '0', 'After', 'tap_amp', ...
    'Position', [560 220 590 250]);
add_block('simulink/Sources/Step', [mdl '/Tap off'], ...
    'Time', 'tap_time + tap_len', 'Before', '0', 'After', '-tap_amp', ...
    'Position', [560 280 590 310]);
add_block('simulink/Math Operations/Sum', [mdl '/Tap'], ...
    'Inputs', '++', 'Position', [630 245 660 285]);
add_block('simulink/Math Operations/Sum', [mdl '/Add disturbance'], ...
    'Inputs', '++', 'Position', [730 115 760 145]);

%% 4. Demux: split the 4 states
add_block('simulink/Signal Routing/Demux', [mdl '/Demux'], ...
    'Outputs', '4', 'Position', [540 300 545 380]);

%% 5. Gain: radians -> degrees (on alpha)
add_block('simulink/Math Operations/Gain', [mdl '/rad2deg'], ...
    'Gain', '180/pi', 'Position', [620 325 670 355]);

%% 6. Terminators on theta, theta_dot, alpha_dot
for k = [1 3 4]
    add_block('simulink/Sinks/Terminator', sprintf('%s/Term %d', mdl, k), ...
        'Position', [600 280+20*k 615 295+20*k]);
end

%% 7. Mux and 8. Scope
add_block('simulink/Signal Routing/Mux', [mdl '/Mux'], ...
    'Inputs', '2', 'Position', [820 300 825 360]);
add_block('simulink/Sinks/Scope', [mdl '/Scope'], ...
    'Position', [870 315 900 345]);

%% Wiring
% Main loop: plant -> -K -> saturation -> (+ tap) -> plant
add_line(mdl, 'Furuta plant/1',    'Controller -K/1',   'autorouting', 'on');
add_line(mdl, 'Controller -K/1',   'Saturation/1',      'autorouting', 'on');
add_line(mdl, 'Saturation/1',      'Add disturbance/1', 'autorouting', 'on');
add_line(mdl, 'Add disturbance/1', 'Furuta plant/1',    'autorouting', 'on');

% Tap pulse
add_line(mdl, 'Tap on/1',  'Tap/1',               'autorouting', 'on');
add_line(mdl, 'Tap off/1', 'Tap/2',               'autorouting', 'on');
add_line(mdl, 'Tap/1',     'Add disturbance/2',   'autorouting', 'on');

% Measurements to the scope
add_line(mdl, 'Furuta plant/1', 'Demux/1',   'autorouting', 'on');
add_line(mdl, 'Demux/2',        'rad2deg/1', 'autorouting', 'on');
add_line(mdl, 'rad2deg/1',      'Mux/2',     'autorouting', 'on');
add_line(mdl, 'Saturation/1',   'Mux/1',     'autorouting', 'on');
add_line(mdl, 'Mux/1',          'Scope/1',   'autorouting', 'on');
for k = [1 3 4]
    add_line(mdl, sprintf('Demux/%d', k), sprintf('Term %d/1', k), 'autorouting', 'on');
end

%% Tidy, save, run
try
    Simulink.BlockDiagram.arrangeSystem(mdl);   % R2018b and later
catch
end
save_system(mdl);
sim(mdl);
open_system([mdl '/Scope']);