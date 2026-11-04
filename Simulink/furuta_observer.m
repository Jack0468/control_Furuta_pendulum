%% build_furuta_observer_loop.m
% Builds the OBSERVER-BASED state-feedback loop for the Furuta pendulum:
%
%   [Saturation] --u--> (+ tap) --> [Furuta plant] --y = [theta; alpha]-->
%        ^                                   |
%        |              [Mux: u, y] <--------+
%        |                   |
%   [Controller -K] <-- xhat [Observer]
%
% The plant now only outputs what the encoders measure (theta, alpha).
% The observer estimates all 4 states from u and y, and -K acts on the estimate.
%
% Observer as one State-Space block:
%   xhat' = (A - L*C)*xhat + [B L]*[u; y],   output = xhat
%
% Run your design script FIRST so A, B, C and K are in the workspace.

%% Check the workspace
if ~exist('A','var') || ~exist('B','var') || ~exist('C','var') || ~exist('K','var')
    error('Run your design script first so A, B, C and K are in the workspace.');
end
if ~isequal(size(K), [1 4])
    error(['K is %dx%d, but it should be the 1x4 controller gain from place(A,B,p). ' ...
           'If your stiffness matrix is also called K, rename it (e.g. Ks).'], ...
           size(K,1), size(K,2));
end
if ~isequal(size(C), [2 4])
    error('C should be the 2x4 sensor matrix [1 0 0 0; 0 1 0 0].');
end

%% Settings (edit these)
x0       = [0; deg2rad(10); 0; 0];  % plant starts with the pendulum tilted 10 deg
xhat0    = zeros(4,1);              % observer starts thinking everything is 0
Vmax     = 10;                      % motor voltage limit (V)
tap_amp  = 1;                       % size of the tap (V)
tap_time = 2;                       % when the tap happens (s)
tap_len  = 0.1;                     % how long the tap lasts (s)
p_obs    = [-40 -45 -50 -55];       % observer poles (~3x faster than controller)

%% Observer gain
fprintf('rank(obsv(A,C)) = %d (n = 4)\n', rank(obsv(A, C)));
L = place(A', C', p_obs)';          % 4x2
disp('Observer gain L ='); disp(L)
disp('Observer poles eig(A - L*C):'); disp(eig(A - L*C).')

%% Create a fresh model
mdl = 'furuta_observer_loop';
if bdIsLoaded(mdl), close_system(mdl, 0); end
if exist([mdl '.slx'], 'file'), delete([mdl '.slx']); end
new_system(mdl);
open_system(mdl);
set_param(mdl, 'StopTime', '4', 'Solver', 'ode45', 'MaxStep', '1e-3');

%% 1. Plant: outputs only the measured signals y = [theta; alpha]
add_block('simulink/Continuous/State-Space', [mdl '/Furuta plant'], ...
    'A', 'A', 'B', 'B', 'C', 'C', 'D', 'zeros(2,1)', ...
    'Position', [380 100 480 160]);

%% 2. Observer: estimates all 4 states from [u; y]
add_block('simulink/Continuous/State-Space', [mdl '/Observer'], ...
    'A', 'A - L*C', 'B', '[B L]', 'C', 'eye(4)', 'D', 'zeros(4,3)', ...
    'Position', [380 220 480 280]);

% Initial conditions (parameter name differs between MATLAB releases)
try
    set_param([mdl '/Furuta plant'], 'InitialCondition', 'x0');
    set_param([mdl '/Observer'],     'InitialCondition', 'xhat0');
catch
    set_param([mdl '/Furuta plant'], 'X0', 'x0');
    set_param([mdl '/Observer'],     'X0', 'xhat0');
end

% Mux that builds the observer input [u; theta; alpha]
add_block('simulink/Signal Routing/Mux', [mdl '/Observer input'], ...
    'Inputs', '2', 'Position', [320 225 325 275]);

%% 3. Controller: Gain -K (acts on the ESTIMATED states)
add_block('simulink/Math Operations/Gain', [mdl '/Controller -K'], ...
    'Gain', '-K', 'Multiplication', 'Matrix(K*u)', ...
    'Position', [540 230 600 270]);

%% 4. Saturation: +/- Vmax
add_block('simulink/Discontinuities/Saturation', [mdl '/Saturation'], ...
    'UpperLimit', 'Vmax', 'LowerLimit', '-Vmax', ...
    'Position', [640 230 680 270]);

%% Tap disturbance: a short voltage pulse (step on, then step off)
add_block('simulink/Sources/Step', [mdl '/Tap on'], ...
    'Time', 'tap_time', 'Before', '0', 'After', 'tap_amp', ...
    'Position', [160 20 190 50]);
add_block('simulink/Sources/Step', [mdl '/Tap off'], ...
    'Time', 'tap_time + tap_len', 'Before', '0', 'After', '-tap_amp', ...
    'Position', [160 70 190 100]);
add_block('simulink/Math Operations/Sum', [mdl '/Tap'], ...
    'Inputs', '++', 'Position', [220 45 250 75]);
add_block('simulink/Math Operations/Sum', [mdl '/Add disturbance'], ...
    'Inputs', '++', 'Position', [300 115 330 145]);

%% 5. Scope signals: true alpha and estimated alpha, in degrees
add_block('simulink/Signal Routing/Demux', [mdl '/Demux y'], ...
    'Outputs', '2', 'Position', [540 100 545 160]);          % theta, alpha
add_block('simulink/Signal Routing/Demux', [mdl '/Demux xhat'], ...
    'Outputs', '4', 'Position', [540 320 545 400]);          % estimates
add_block('simulink/Math Operations/Gain', [mdl '/rad2deg'], ...
    'Gain', '180/pi', 'Position', [620 125 670 155]);
add_block('simulink/Math Operations/Gain', [mdl '/rad2deg hat'], ...
    'Gain', '180/pi', 'Position', [620 345 670 375]);

add_block('simulink/Sinks/Terminator', [mdl '/Term theta'], 'Position', [600 95 615 110]);
for k = [1 3 4]
    add_block('simulink/Sinks/Terminator', sprintf('%s/Term hat %d', mdl, k), ...
        'Position', [600 300+20*k 615 315+20*k]);
end

% Scope inputs: 1 = u (V), 2 = alpha (deg), 3 = alpha estimate (deg)
add_block('simulink/Signal Routing/Mux', [mdl '/Mux'], ...
    'Inputs', '3', 'Position', [820 200 825 290]);
add_block('simulink/Sinks/Scope', [mdl '/Scope'], ...
    'Position', [870 230 900 260]);

%% Wiring
% Plant input: saturated voltage + tap
add_line(mdl, 'Saturation/1',      'Add disturbance/1', 'autorouting', 'on');
add_line(mdl, 'Tap on/1',          'Tap/1',             'autorouting', 'on');
add_line(mdl, 'Tap off/1',         'Tap/2',             'autorouting', 'on');
add_line(mdl, 'Tap/1',             'Add disturbance/2', 'autorouting', 'on');
add_line(mdl, 'Add disturbance/1', 'Furuta plant/1',    'autorouting', 'on');

% Observer input: applied voltage u (before the tap) and measurements y
add_line(mdl, 'Saturation/1',     'Observer input/1', 'autorouting', 'on');
add_line(mdl, 'Furuta plant/1',   'Observer input/2', 'autorouting', 'on');
add_line(mdl, 'Observer input/1', 'Observer/1',       'autorouting', 'on');

% Controller acts on the estimate
add_line(mdl, 'Observer/1',      'Controller -K/1', 'autorouting', 'on');
add_line(mdl, 'Controller -K/1', 'Saturation/1',    'autorouting', 'on');

% Scope
add_line(mdl, 'Furuta plant/1', 'Demux y/1',     'autorouting', 'on');
add_line(mdl, 'Demux y/1',      'Term theta/1',  'autorouting', 'on');
add_line(mdl, 'Demux y/2',      'rad2deg/1',     'autorouting', 'on');
add_line(mdl, 'Observer/1',     'Demux xhat/1',  'autorouting', 'on');
add_line(mdl, 'Demux xhat/2',   'rad2deg hat/1', 'autorouting', 'on');
for k = [1 3 4]
    add_line(mdl, sprintf('Demux xhat/%d', k), sprintf('Term hat %d/1', k), 'autorouting', 'on');
end
add_line(mdl, 'Saturation/1',  'Mux/1',   'autorouting', 'on');
add_line(mdl, 'rad2deg/1',     'Mux/2',   'autorouting', 'on');
add_line(mdl, 'rad2deg hat/1', 'Mux/3',   'autorouting', 'on');
add_line(mdl, 'Mux/1',         'Scope/1', 'autorouting', 'on');

%% Tidy, save, run
try
    Simulink.BlockDiagram.arrangeSystem(mdl);   % R2018b and later
catch
end
save_system(mdl);
sim(mdl);
open_system([mdl '/Scope']);