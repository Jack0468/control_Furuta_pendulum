# 05: Simulation and Test Plan (Lab 9 A2, Lab 10 A3, Lab 11)

Every design is tested on two plants:

- The **linear model**, `ss(A,B,C,D)`. This is the model the design assumes.
- The **nonlinear truth model**, `furuta_nl.m` via `furuta_sim_cl.m`, with ±10 V saturation. Optionally add encoder quantisation and noise.

## Test matrix

| ID | Test | Input / condition | Plant | Pass criterion | Week | Script |
| --- | --- | --- | --- | --- | --- | --- |
| T1 | Open-loop release | α₀ = 2°, u = 0 | Lin + NL | Shows instability; linear and nonlinear agree to about 15° | 9 | `week9_model_and_openloop` |
| T2 | Open-loop voltage pulse | 1 V for 50 ms | Lin + NL | Shows coupling and the fall | 9 | `week9_model_and_openloop` |
| T3 | Parameter sensitivity, open loop | ±20% on 7 parameters | Lin | Report the movement of the unstable pole | 9 | `week9_model_and_openloop` |
| T4 | Balance recovery | α₀ = 10° | NL + sat | R2, R5, R9 | 10 | `week10_state_feedback` |
| T5 | Arm step | r = 30° | Lin + NL | R3, R4, R5 | 10 | `week10_state_feedback` |
| T6 | Pendulum tap | τ_p = 20 mN·m for 20 ms | NL + sat | R6, R9 | 10 | `week10_state_feedback` |
| T7 | Arm drag | τ_d = 2 mN·m from t = 2 s | NL + sat | R7 (with integrator) | 10 | `week10_state_feedback` §6 |
| T8 | Region of attraction | α₀ swept 2° → 40° | NL + sat | Report the largest recovered α₀ | 10 | `week10_state_feedback` §4 |
| T9 | Robustness | ±20% on 6 parameters, nominal K | Lin (+ NL) | R8: poles stay in the LHP; R2 still met | 10 | `week10_state_feedback` §5 |
| T10 | Observer convergence | x̂(0) = 0, α₀ = 10° | NL + sat | Recovers; estimation error → 0 | 11 | `week11_observer` (to write) |
| T11 | Measurement noise | y quantised to 3.07 mrad + white noise | NL + sat | V_m noise < ~0.5 V rms; no chatter | 11 | `week11_observer` |
| T12 | Observer + uncertainty | Perturbed plant, nominal observer | NL + sat | R1, R2 still met | 11 | `week11_observer` |
| T13 | Sampling (stretch) | Discretise K and L at T_s = 1 ms (`c2d`) | NL + sat | Matches continuous-time performance | 11+ | — |

## Figures for the report

| Figure | Shows | Status |
| --- | --- | --- |
| `w9_openloop_release.png` | T1 | Done |
| `w9_pulse_response.png` | T2 | Done |
| `w10_nonlinear_tests.png` | T4–T6 for D2 (θ, α, V_m) | Done |
| `w10_integral_action.png` | T6 + T7, with and without the integrator | Done |
| `w10_pole_map.png` | Open-loop and closed-loop poles for D1/D2/D3/LQR against the ζ ≥ 0.69 and ζω_n ≥ 2 boundaries | Done |
| `w10_design_comparison.png` | D1/D2/D3/LQR 30° step: θ, α, V_m overlaid | Done |
| `w11_observer_error.png` | T10 estimation error | To do |
| `w11_noise.png` | T11 V_m for slow vs fast observer poles | To do |

## Lab 10 questions → evidence

| Lab 10 item | Figure | Written answer |
| --- | --- | --- |
| A1: Why does it need control? | `w9_openloop_release.png` (falls past 15° in 0.23 s) | doc 03 §1 |
| A1: Measurements, actuation, constraints | None (text answer; V_m limit shown on `w10_nonlinear_tests.png`) | doc 03 §1 |
| A1: Design requirements (rise time, settling time, overshoot) | None (table) | doc 03 §2 |
| A2: Requirements → pole locations | `w10_pole_map.png` | doc 03 §3 |
| A2: Reachability, gains K | None (rank and K in console output) | doc 02 §5, doc 04 §2 |
| A3: Does it meet the requirements? | `w10_design_comparison.png` | doc 04 §2 |
| A3: Disturbance rejection | `w10_nonlinear_tests.png` (right column), `w10_integral_action.png` | doc 04 §3 |
| A3: Actuator saturation | `w10_nonlinear_tests.png` (bottom row), `w10_design_comparison.png` (bottom) | doc 04 §2–3 |
| A3: Linear controller on the nonlinear plant | `w10_nonlinear_tests.png` | doc 04 §3 |
| A3: Try several pole sets | `w10_pole_map.png`, `w10_design_comparison.png` | doc 04 §2 |

## Reporting checklist (Assessment 2)

- [ ] Inputs, outputs, states and disturbances defined (doc 02 §1)
- [ ] Nonlinear model, linearisation and A, B, C, D with numbers (doc 02 §2–3)
- [ ] Parameters with citations (doc 02 §4)
- [ ] Reachability and observability shown (doc 02 §5)
- [ ] Lab 10 questions answered and requirements justified (doc 03)
- [ ] Requirements → poles → K, with iterations shown (doc 03 §3, doc 04 §2)
- [ ] Saturation, disturbances and uncertainty tested and discussed (T4–T9)
- [ ] Observer designed and tested (T10–T12)
- [ ] Limitations discussed: RHP pole/zero, linear validity, damping uncertainty
