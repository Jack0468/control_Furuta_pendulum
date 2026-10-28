function run_all()
%RUN_ALL Reproduce every numerical result and figure in the report.
%   Run from the matlab/ folder. Requires the Control System Toolbox.
%   Figures are written to ../figures. Total run time is about 5 minutes (R2025b).
scripts = {'week9_model_and_openloop', ...           % model, open loop (Lab 9)
           'week10_state_feedback', ...              % pole placement, LQR, integrator (Lab 10)
           'week10_pole_placement_derivation', ...   % hand derivation check (doc 06)
           'week11_observer', ...                    % observer design and tests
           'week11_kalman', ...                      % Kalman filter study (doc 09)
           'week12_validation'};                     % V1-V7 on the nonlinear plant
for i = 1:numel(scripts)
    fprintf('\n===== %s =====\n', scripts{i});
    t0 = tic;
    run_one(scripts{i});
    close all;
    fprintf('----- %s done in %.0f s\n', scripts{i}, toc(t0));
end
end

function run_one(name)
% Each script starts with "clear", so it runs in this function's own workspace.
run(name);
end
