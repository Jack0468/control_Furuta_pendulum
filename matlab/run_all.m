function run_all()
%RUN_ALL Reproduce every numerical result and figure in the report.
%   Run from the matlab/ folder. Requires the Control System Toolbox.
%   Figures are written to ../figures. Total run time is 3-7 minutes (R2025b).
%   The Kalman filter study (week11_kalman, doc 09) is separate: the report doesn't use it.
scripts = {'week9_model_and_openloop', ...           % model, open loop (Lab 9)
           'week10_state_feedback', ...              % pole placement, integrator (Lab 10)
           'week10_pole_placement_derivation', ...   % hand derivation check (doc 06)
           'week11_observer', ...                    % observer design, analytical gain, tests
           'week12_validation', ...                  % V1-V9 on the nonlinear plant
           'week12_margins'};                        % Bode/Nyquist margins, gain ranges, linear vs nonlinear
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
