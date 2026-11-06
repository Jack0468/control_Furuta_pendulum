# Furuta Pendulum: Upright Balance Control

ELEC3304 Control, Open Design Project (University of Sydney, 2026 S2). Due 6 November 2026.

We balance a Furuta (rotary inverted) pendulum in its upright position using **observer-based state feedback**.

- **Model:** nonlinear Lagrangian, linearised about upright, giving a 4-state LTI model. One actuator (motor voltage), two sensors (arm and pendulum encoders). The arm is modelled as a uniform bar with the motor at one end, so J_r = m_rL_r²/3 ([why](docs/02_system_model.md#41-arm-geometry-assumption)).
- **Controller:** pole-placed state feedback with integral action on the arm angle (type-1 servo).
- **Observer:** a discrete-time observer estimates the two unmeasured velocities from quantised encoder readings.
- **Validation:** everything is tested on the full nonlinear model at 1 kHz, with datasheet-based encoder noise, motor saturation, disturbances and ±20% parameter uncertainty.

Progress, decisions and open issues are tracked in **[docs/LOGBOOK.md](docs/LOGBOOK.md)**. Everything still to do is in **[docs/TODO.md](docs/TODO.md)**.

## Documents

| File | Contents | Report section |
| --- | --- | --- |
| [docs/LOGBOOK.md](docs/LOGBOOK.md) | Dated work log, decision register, open issues, plan to submission | — |
| [docs/TODO.md](docs/TODO.md) | Checklist of everything still open, with owner and date | — |
| [docs/01_blueprint.md](docs/01_blueprint.md) | Feasibility, scope, control architecture, risks | Introduction |
| [docs/02_system_model.md](docs/02_system_model.md) | Signals; nonlinear equations of motion derived step by step with references; linearisation; A/B/C/D; parameters; model properties | System Model, Problem Definition |
| [docs/03_design_requirements.md](docs/03_design_requirements.md) | Why control is needed, constraints, requirements R1–R9 → pole locations | Problem Definition |
| [docs/04_controller_and_observer.md](docs/04_controller_and_observer.md) | Pole placement, LQR comparison, integral action, type-1 servo, observer design and pole choice | Controller Design |
| [docs/05_test_plan.md](docs/05_test_plan.md) | Test matrix, figure list, validation results vs requirements | Numerical Validations |
| [docs/06_pole_placement_derivation.md](docs/06_pole_placement_derivation.md) | Hand derivation of K (coefficient matching), with Ackermann and `place` cross-checks | Controller Design |
| [docs/07_code_explained.md](docs/07_code_explained.md) | The MATLAB code explained from first principles | — |
| [docs/08_sensors_and_noise.md](docs/08_sensors_and_noise.md) | Encoder selection and noise model from the Broadcom/US Digital datasheets | System Model |
| [docs/09_kalman_filter.md](docs/09_kalman_filter.md) | Kalman filter derivation and comparison with pole-placed observers | Background, not in the report |
| [docs/10_literature_review.md](docs/10_literature_review.md) | Sources and how far each was verified; material for the Introduction and System Model; rubric coverage | Introduction, System Model |
| [references/README.md](references/README.md) | Sources for the local reference PDFs (the PDFs themselves are not in the public repo) | — |

## MATLAB code (`matlab/`)

| File | Purpose |
| --- | --- |
| `run_all.m` | **Reproduces every result and figure** (3–7 min) |
| `furuta_params.m` | Physical, motor and encoder parameters |
| `furuta_linmodel.m` | Linearised A, B, C, D about upright |
| `furuta_nl.m` | Full nonlinear dynamics (truth model), with disturbance torques |
| `furuta_design.m` | Final controller gains (Kₓ, kᵢ) and observer gain L |
| `furuta_savefig.m` | Formats figures for the report; `FURUTA_FIGDIR` previews them elsewhere |
| `furuta_sim_cl.m` | Continuous-time, full-state closed loop (Week 10 studies) |
| `furuta_sim_obs.m` | Final sampled-data loop: encoders, observer, saturation, anti-windup, noise |
| `week9_model_and_openloop.m` | Model checks, linear vs nonlinear open loop, uncertainty sweep |
| `week10_state_feedback.m` | Requirements → poles, `place`/`lqr`, nonlinear evaluation, robustness |
| `week10_pole_placement_derivation.m` | Reproduces every number in doc 06 |
| `week11_observer.m` | Observer design, analytical gain, separation-principle check, pole choice, velocity estimate |
| `week11_kalman.m` | Steady-state Kalman filter study (background; `run_all` skips it) |
| `week12_validation.m` | Validation tests V1–V9 on the nonlinear plant |
| `week12_margins.m` | Bode/Nyquist margins, stable gain ranges, linear vs nonlinear, published parameter values |
| `week12_tray_mass.m` | Background: effect of a tip mass (run directly; not used in the report or the Canvas zip) |

```matlab
cd matlab
run_all
```

Requires the Control System Toolbox. Tested on MATLAB R2025b. Figures go to `figures/`. To build the report PDF: `python report/build.py`. The geometry diagram in the appendix (`figures/furuta_diagram.png`) is drawn by `python report/furuta_diagram.py` (matplotlib).

## Key numbers

- **Open-loop poles:** 0, −14.06, **+12.09**, −1.75 rad/s. Released at 2°, the pendulum passes 15° in 0.22 s.
- **Structure:** reachable (rank 4); observable from both encoders (rank 4). θ/V_m has a right-half-plane zero at **+10.31 rad/s** (non-minimum phase).
- **Sensors:** 512-CPR optical encoders in 4× quadrature. Resolution q = 3.07 mrad; quantisation noise σ = 0.886 mrad.
- **Final design:**
  - Controller poles −2.7 ± 2.38j, −10.8, −13.5, −5 (integrator).
  - Observer poles −100 … −130.
  - 30° step: T_s 1.38 s, overshoot 1.4%, rise time 0.75 s (doc 05).
  - Recovers from a 10° tilt in 0.97 s, using at most 6.6 V. A firm tap peaks at 14.6° (limit 15°).
  - Phase margin 36°, gain margins ×0.59 and ×6.7. Stays upright on 31 of 40 random ±20% plants under a tap.

## Repository layout

```
docs/        design documents and logbook
report/      LaTeX report, build.py (run: python report/build.py) and furuta_diagram.py
matlab/      all code (run_all.m reproduces everything)
figures/     generated figures
references/  local copies of course PDFs and datasheets (git-ignored; README lists sources)
scratch/     working scripts and drafts (git-ignored)
```
