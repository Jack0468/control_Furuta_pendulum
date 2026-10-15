# Furuta Pendulum: Upright Balance Control

ELEC3304 Control, Assessment 2 project (Practicals Weeks 9–11).

**Verdict: feasible.** We linearise a Furuta (rotary inverted) pendulum about its upright equilibrium. This gives a 4-state LTI model with one actuator (motor voltage) and two sensors (arm and pendulum encoders). The model meets all five Lab 9 requirements, and it leads straight into state feedback (Week 10) and an observer (Week 11). See [docs/01_blueprint.md](docs/01_blueprint.md) for the full justification and the caveats to raise with the tutor.

## Documents

| File | Contents | Practical |
| --- | --- | --- |
| [docs/01_blueprint.md](docs/01_blueprint.md) | Feasibility, scope, control architecture, plan, risks, tutor questions | All |
| [docs/02_system_model.md](docs/02_system_model.md) | Signals, nonlinear EOM, linearisation, A/B/C/D, parameters, model properties | Lab 9 A1 |
| [docs/03_design_requirements.md](docs/03_design_requirements.md) | Answers to the Lab 10 A1 questions, constraints, uncertainty, requirements → poles | Lab 10 A1 |
| [docs/04_controller_and_observer.md](docs/04_controller_and_observer.md) | Pole placement results, LQR comparison, integral action, observer plan | Lab 10 A2–A3, Lab 11 |
| [docs/05_test_plan.md](docs/05_test_plan.md) | Simulation test matrix, pass criteria, figures to produce | Lab 9 A2, Lab 10 A3 |
| [docs/06_pole_placement_derivation.md](docs/06_pole_placement_derivation.md) | Step-by-step hand derivation of K (coefficient matching), Ackermann and `place` cross-checks | Lab 10 A2 |

## MATLAB code (`matlab/`)

| File | Purpose |
| --- | --- |
| `furuta_params.m` | Nominal parameters (Quanser QUBE-Servo 2 based) |
| `furuta_linmodel.m` | Linearised A, B, C, D about upright |
| `furuta_nl.m` | Full nonlinear dynamics (truth model), with disturbance torques |
| `furuta_sim_cl.m` | Nonlinear closed-loop simulation with saturation and disturbances |
| `week9_model_and_openloop.m` | Model checks, linear vs nonlinear open loop, uncertainty sweep |
| `week10_state_feedback.m` | Requirements → poles, `place`/`lqr`, nonlinear evaluation, robustness |
| `week10_pole_placement_derivation.m` | Reproduces every number in doc 06 (no Symbolic Toolbox needed) |

Run from inside `matlab/`. Requires the Control System Toolbox. Tested on R2025b. Figures are written to `figures/`.

```matlab
cd matlab
week9_model_and_openloop
week10_state_feedback
```

## Key numbers (nominal model)

- Open-loop poles: 0, −30.05, **+10.55**, −6.12 rad/s. The unstable time constant is 95 ms, and released from 2° the pendulum passes 15° after 0.23 s.
- Reachability rank 4/4. Observability rank 4/4 with both encoders, 4/4 with θ alone, and only 3/4 with α alone.
- θ/V_m has a right-half-plane zero at **+8.97 rad/s**. The system is non-minimum phase: the arm first moves the wrong way.
