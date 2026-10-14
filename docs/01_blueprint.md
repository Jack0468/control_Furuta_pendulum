# 01: Project Blueprint

## 1. Feasibility verdict

**Yes, the project is feasible.** A Furuta pendulum balanced upright is a standard control benchmark. Linearising about α = 0 (upright) gives a well-conditioned 4-state LTI model that satisfies every Lab 9 requirement.

| Lab 9 requirement | How this project meets it |
| --- | --- |
| 1. At least two states | 4 states: x = [θ, α, θ̇, α̇]ᵀ |
| 2. Fewer sensors than states | 2 encoders (θ, α) for 4 states. θ̇ and α̇ must be estimated, so the Week 11 observer is necessary |
| 3. Reasonable parameters | Taken from the Quanser QUBE-Servo 2 rotary pendulum (see [02_system_model.md](02_system_model.md)) |
| 4. LTI state-space form | ẋ = Ax + Bu, y = Cx after linearisation |
| 5. At least one actuator, reachable | Motor voltage V_m. rank(ctrb(A,B)) = 4 (verified in MATLAB) |

### Caveats: check these with the tutor in the Week 9 session

1. **Similarity to lecture examples.** The cart–pole inverted pendulum is a common lecture or tutorial example. The Furuta pendulum is a different plant: it is rotary, the arm and pendulum are coupled through Coriolis and centripetal terms, and the motor's back-EMF enters the model. Even so, get explicit approval. If the tutor says no, fall-back plants that reuse most of this work are a reaction-wheel pendulum or a ball-and-beam.
2. **The linear model is local.** It is valid for roughly |α| < 15°. The scope is therefore *balance plus arm positioning, starting near upright*. Swing-up from hanging is a stretch goal and is not needed for the assessment.
3. **The unstable pole is fast** (+10.55 rad/s), and the input saturates at ±10 V. This limits how large a disturbance can be recovered. That is a feature for the Assessment 2 discussion, not a blocker.

## 2. Scope

| In scope (core) | Stretch goals |
| --- | --- |
| LTI model about upright; nonlinear truth model | Energy-based swing-up and switching to the balance controller |
| State feedback by pole placement (Week 10) | Discrete-time implementation at 1 kHz |
| LQR as a comparison design | Kalman filter instead of a pole-placed observer |
| Reference tracking of the arm angle θ | Coulomb friction and encoder-quantisation models |
| Integral action to reject constant arm torque | Robustness sweep (Monte Carlo over parameters) |
| Luenberger observer for θ̇, α̇ (Week 11) | |
| Tests: saturation, disturbances, ±20% parameter error | |

## 3. Control architecture

```
             r (θ ref)                       τ_d, τ_p (disturbances)
                │                                   │
                ▼                                   ▼
          ┌───────────┐  u   ┌───────────┐  V_m  ┌──────────────────┐   y = [θ, α] + n
 x̂ ─────▶ │ u = -K(x̂ - │ ───▶ │ saturation│ ────▶ │ Furuta pendulum  │ ──────────┬────▶
          │   [r,0,0,0])│     │  ±10 V    │       │ (nonlinear plant)│           │
          │  (+ ∫ e_θ)  │     └───────────┘       └──────────────────┘           │
          └───────────┘           │                                              │
                ▲                 │ u (applied)                                  │
                │                 ▼                                              │
                │         ┌──────────────────────────────┐                      │
                └──────── │ Observer:                    │ ◀────────────────────┘
                     x̂    │ x̂̇ = Ax̂ + Bu + L(y - Cx̂)     │
                          └──────────────────────────────┘
```

- Week 10 designs K assuming the full state x is available.
- Week 11 replaces x with the observer estimate x̂. By the separation principle, the controller poles (A − BK) and the observer poles (A − LC) can be designed independently.
- Feed the **saturated** voltage to the observer, otherwise its estimate drifts while the actuator is saturated.

## 4. Week-by-week plan

| Week | Practical goal | Deliverables in this repo | Status |
| --- | --- | --- | --- |
| 9 | Model and open-loop simulation | `02_system_model.md`, `week9_model_and_openloop.m`, `figures/w9_*.png` | Drafted |
| 10 | Requirements and state feedback | `03_design_requirements.md`, `04_controller_and_observer.md` §1–3, `week10_state_feedback.m` | Drafted; add integral action |
| 11 | Observer and observer-based feedback | `04_controller_and_observer.md` §4, `week11_observer.m` (to write) | Not started |
| 12+ | Assessment 2 report | Report built from docs 02–05 and the figures | Not started |

Suggested split for a group of two:

- **Student A:** modelling, nonlinear simulation, test harness (`furuta_nl.m`, `furuta_sim_cl.m`, [05_test_plan.md](05_test_plan.md)).
- **Student B:** requirements, controller and observer design, robustness study.
- **Together:** reviewing each other's derivations and writing the report.

## 5. Risks

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Tutor rules the plant too close to a lecture example | Must change plant | Ask in Week 9; have a reaction-wheel pendulum ready as fall-back |
| Parameters (D_r, D_p) are uncertain | Model mismatch | Treat as uncertain (±20–50%) and show robustness |
| Aggressive gains saturate the motor | Loss of balance | Compare pole sets; report the recoverable α₀ for each |
| RHP zero (+8.97 rad/s) limits θ tracking | Undershoot, slower tracking | Keep dominant θ bandwidth ≈ 4 rad/s; discuss as a fundamental limitation |
| Constant arm torque (cable drag) causes θ offset | Fails tracking requirement | Add an integrator on θ (augmented 5-state design) |
| Observer amplifies encoder quantisation | Noisy V_m, chatter | Observer poles 2–5× faster than the controller, not 20×; test with quantised y |

## 6. Questions to ask the tutor

1. Is a Furuta pendulum acceptable given that the cart–pole was covered in lectures?
2. Is a balance-only scope (start within ±10° of upright) acceptable, with swing-up optional?
3. Are parameters based on the Quanser QUBE-Servo 2 acceptable as "researched" values, and should we cite the manual?
4. Should the assessed controller be designed in continuous time, or should we discretise it?
5. Is integral action (an augmented state) allowed within "state feedback by pole placement"?

## 7. References

- B. S. Cazzolato and Z. Prime, "On the Dynamics of the Furuta Pendulum," *Journal of Control Science and Engineering*, 2011, Article ID 528341.
- K. Furuta, M. Yamakita and S. Kobayashi, "Swing-up control of inverted pendulum using pseudo-state feedback," *Proc. IMechE Part I*, 1992.
- Quanser, *QUBE-Servo 2 User Manual* and *Rotary Pendulum Workbook (Student)*. These are the source of the nominal parameters; check the values against your copy.
- K. J. Åström and K. Furuta, "Swinging up a pendulum by energy control," *Automatica* 36(2), 2000. Relevant for the swing-up stretch goal.
