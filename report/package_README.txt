Observer-Based State Feedback for Upright Stabilisation of a Furuta Pendulum
ELEC3304 Open Design Project: code to reproduce every numerical result and figure in the report
=============================================================================================

REQUIREMENTS
  MATLAB with the Control System Toolbox (tested on R2025b, Windows 11). No other toolboxes.
  Python 3.9+ with matplotlib, only for the geometry diagram (Fig. 3).

HOW TO REPRODUCE
  1. Unzip, then in MATLAB change into the matlab/ folder.
  2. Run:  run_all
     This runs the six scripts below in order (3-7 minutes). Figures are written as PNG files
     to ../figures (created if missing), and every number quoted in the report is printed to
     the Command Window.
  3. Compare the printed output with expected_results.txt (the output of the same run).
  4. Optional, Fig. 3:  python python/furuta_diagram.py   (writes figures/furuta_diagram.png)

  The random parameter sets and noise use fixed seeds (rng(7) for the Monte Carlo test,
  rng(1) for the observer-speed study, per-run seeds in furuta_sim_obs), so the output is
  identical on every run.

WHAT EACH FILE REPRODUCES (report section, equation, table or figure)
  Model and design functions
    furuta_params.m        Table I parameters (J_r = m_r L_r^2 / 3).
    furuta_nl.m            nonlinear equations of motion (4)-(6), Section II-A.
    furuta_linmodel.m      linearisation and the A, B, C matrices, Section III-B.
    furuta_design.m        final gains K_x, k_i (Section IV-B) and observer gain L_d (IV-C).
    furuta_sim_obs.m       1 kHz sampled loop: nonlinear plant, quantised encoders (7),
                           +/-10 V saturation, disturbances, state observer, integral action.
    furuta_sim_cl.m        nonlinear plant with full-state feedback (no observer).
    furuta_savefig.m       figure formatting and export.

  Scripts (run by run_all)
    week9_model_and_openloop.m          open-loop poles, right-half-plane zero (III-B);
                                        open-loop release, Fig. 7.
    week10_state_feedback.m             candidate designs D1-D4, Table III; drag offset without
                                        the integrator (26 deg), Section IV-B.
    week10_pole_placement_derivation.m  hand derivation of the gains by coefficient matching,
                                        and the voltage limit on pole speed (IV-B, Step 7).
    week11_observer.m                   analytical observer gain (15)-(16); observer-speed study,
                                        Table IV; estimation-error convergence, Fig. 6 (V-C).
    week12_validation.m                 tests V1-V9: Table II and Section V; nonlinear responses,
                                        Fig. 1; +/-20% Monte Carlo, Fig. 2 (V-E).
    week12_margins.m                    stable gain ranges, Table V; Bode/Nyquist margins, Fig. 4
                                        (IV-D); linear vs nonlinear model, Fig. 5 (V-B).

  python/furuta_diagram.py              geometry and sign convention, Fig. 3.

  Simulink/ (supplementary, not needed for any number in the report)
    furuta_loop.slx, furuta_observer_loop.slx and their build scripts: an independent Simulink
    implementation of the state-feedback and observer loops on the LINEAR plant. Run a design
    script first so A, B, C and K are in the workspace (see the header of each .m file). For a
    10 deg release and a 1 V tap it agrees with furuta_sim_obs.m to within 0.1 deg RMS in alpha.

SIGN CONVENTION
  theta (arm) is positive anticlockwise seen from above. alpha (pendulum) is measured from
  upright and is positive when the pendulum leans against positive arm rotation (Fig. 3).
