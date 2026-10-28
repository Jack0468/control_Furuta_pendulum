# 07: The Code Explained from First Principles

This document explains what every MATLAB file in `matlab/` does. It traces each line of physics back to its origin: Newton/Lagrange mechanics, Kirchhoff's voltage law, and linear systems theory. Read it alongside the code; line numbers refer to the current files.

---

## 1. How the files fit together

```
furuta_params.m ──► P (struct of physical constants)
        │
        ├──► furuta_nl.m        nonlinear physics: x, V_m → ẋ       ("the real pendulum")
        │         │
        │         └──► furuta_sim_cl.m   integrates furuta_nl with a controller in the loop
        │
        └──► furuta_linmodel.m  linear physics:   A, B, C, D          ("the design model")

week9_model_and_openloop.m          uses linmodel + nl: is the model sensible? how unstable?
week10_state_feedback.m             uses linmodel to design K, then nl + sim_cl to test K
week10_pole_placement_derivation.m  reproduces the hand derivation of K (doc 06)
```

There are **two models of the same machine**:

- **The nonlinear model** (`furuta_nl.m`) is as close to the physics as we go. It stands in for the real hardware.
- **The linear model** (`furuta_linmodel.m`) is an approximation that is only valid near upright. The design tools (`place`, `lqr`, `eig`) require it.

Every controller is **designed on the linear model and tested on the nonlinear one**. That is the core logic of the whole project.

---

## 2. `furuta_params.m`: the physical constants

This file returns a struct `P` holding every number that describes the hardware. All other files read from `P`, so changing a value here propagates everywhere.

### Motor (lines 9–11)

A permanent-magnet DC motor obeys two laws:

1. **Electrical, by Kirchhoff's voltage law around the armature:**
   V_m = R_m·i + L_m·di/dt + k_m·θ̇.
   - R_m·i is the resistive drop.
   - L_m·di/dt is the inductive drop, which we neglect (see §3).
   - k_m·θ̇ is the back-EMF: a spinning motor acts as a generator.
2. **Mechanical, by the Lorentz force on the windings:** the torque is τ = k_t·i.

In SI units k_t = k_m. Both come from the same magnetic flux linkage, and energy conservation (electrical power k_m·θ̇·i = mechanical power τ·θ̇) forces them to be equal. That is why there is a single `P.km`.

`P.Vmax = 10` is the amplifier's output limit, which is the actuator constraint.

### Rigid bodies (lines 14–23)

- **Masses and lengths** are measured quantities (from the QUBE-Servo 2 manual).
- **Moments of inertia** come from J = ∫ r² dm. For a uniform thin rod of mass m and length L, rotating about its centre:

  J = ∫ from −L/2 to L/2 of (m/L)·r² dr = mL²/12.

  - `P.Jp = mp*Lp^2/12` is the pendulum's inertia about its own centre of mass. The Lagrangian (§3) adds the offset to the pivot separately, using the parallel-axis theorem.
  - `P.Jr = mr*Lr^2/12` **assumes the arm rotates about its centre** (the Quanser convention). If your arm is pivoted at one end, the same integral from 0 to L gives mL²/3. That changes the open-loop poles from {+10.55, −6.12, −30.05} to {+9.96, −4.06, −17.73}. **Check this against your hardware.**
- **Damping** `Dr`, `Dp` model bearing friction as a torque proportional to speed (−D·ω). Real friction also has a Coulomb (constant) part. These two values are the least certain numbers in the model.

### Sensors (lines 26–28)

A 2048-count encoder resolves 2π/2048 = 3.07 mrad (0.18°). This sets the quantisation noise level for the Week 11 observer tests. `P.Ts` is reserved for a future discrete-time implementation and is not used yet.

---

## 3. `furuta_nl.m`: the nonlinear physics

This file answers one question: **given the state x and the voltage V_m right now, how fast is each state changing (ẋ)?** That is all an ODE solver needs.

### 3a. Generalised coordinates

The machine has two rigid bodies, each rotating about one axis, so it has **two degrees of freedom**: θ (arm) and α (pendulum, with α = 0 upright). Each degree of freedom has a position and a velocity, which gives **4 states**: x = [θ, α, θ̇, α̇].

### 3b. Derivation by Lagrange's method

Lagrange's method avoids having to find the internal reaction forces at the joints. The steps are:

1. **Position of the pendulum's centre of mass.** Let l = L_p/2. The arm tip is at L_r(cos θ, sin θ, 0). The pendulum tilts in the plane perpendicular to the arm. Positive α tilts it backwards, against positive arm rotation:

   p = (L_r cos θ + l sin α sin θ,  L_r sin θ − l sin α cos θ,  l cos α)

2. **Velocity squared**, found by differentiating p and simplifying:

   |ṗ|² = L_r²θ̇² − 2L_r l cos α·θ̇α̇ + l²α̇² + l² sin²α·θ̇²

3. **Kinetic energy T** (translational plus rotational):

   T = ½J_rθ̇² + ½m_p|ṗ|² + ½J_pα̇²

   This neglects the pendulum's own spin term ½J_p sin²α·θ̇². Quanser's model makes the same simplification. The term is second-order small near upright, so it does not affect the linear model.

4. **Potential energy:** V = m_p g l cos α. It is largest when upright, which is why upright is unstable.

5. **Euler–Lagrange equation** for each coordinate q ∈ {θ, α}:

   d/dt(∂L/∂q̇) − ∂L/∂q = Q_q,  where L = T − V

   Q_q is the generalised force: everything that is not a conservative force. For the arm, Q_θ = τ − D_rθ̇ + τ_d. For the pendulum, Q_α = −D_pα̇ + τ_p.

Carrying out step 5 gives exactly the two equations in doc 02 §2. In the α equation, the ±½m_pL_pL_r sin α·θ̇α̇ terms cancel, which is why that term does not appear.

### 3c. How the code implements it

- **Line 14 — motor torque.** τ = k_m(V_m − k_m θ̇)/R_m. Solve the KVL equation for i with L_m = 0, then use τ = k_m·i. Inductance is neglected because the electrical time constant L_m/R_m is well under 1 ms, much faster than the mechanics.
- **Lines 16–17 — mass matrix M(α).** The two Euler–Lagrange equations always have the form M(α)·[θ̈; α̈] = f. M collects every term multiplied by an acceleration:
  - M₁₁ = J_r + m_pL_r² + ¼m_pL_p² sin²α: the arm's inertia, plus the pendulum mass carried at the tip, plus the extra inertia when the pendulum leans out.
  - M₂₂ = J_p + ¼m_pL_p²: the pendulum's inertia about its pivot (parallel-axis theorem).
  - M₁₂ = M₂₁ = −½m_pL_pL_r cos α: the coupling. Accelerating the arm swings the pendulum, and vice versa.
- **Lines 19–20 — right-hand side f.** f collects everything else, moved to the right-hand side:
  - **Arm row:** motor torque, minus friction, minus the Coriolis term (θ̇α̇) and centripetal term (α̇²), plus the disturbance τ_d.
  - **Pendulum row:** minus friction, plus the centrifugal term (θ̇² flings the pendulum outward), plus gravity (½m_p g L_p sin α), plus the disturbance τ_p.
- **Line 22 — solve for the accelerations.** `M\f` solves the 2×2 linear system for [θ̈; α̈]. The backslash is MATLAB's linear solver, which is better than `inv(M)*f`. M is always invertible, because its determinant is positive (it represents kinetic energy, which is positive for any motion). The derivative of the state is then ẋ = [θ̇; α̇; θ̈; α̈]: the first two entries are just the current velocities.

---

## 4. `furuta_linmodel.m`: the linear model

The design tools only work for ẋ = Ax + Bu. This file approximates the nonlinear model near upright.

### 4a. Why linearise, and where

A smooth nonlinear function can be approximated near an operating point by its first-order Taylor expansion. The operating point must be an **equilibrium** (ẋ = 0 there), otherwise the approximation drifts immediately.

At x = 0, V_m = 0, every term in f is zero, so upright-and-stationary is an equilibrium. It is unstable, which is why we need control.

### 4b. The approximation

Near α = 0, use sin α ≈ α and cos α ≈ 1. Any product of two small quantities (sin²α, θ̇α̇, α̇², θ̇²) is negligible compared with single small quantities, so drop it. This is equivalent to taking the Jacobian of furuta_nl at x = 0. The two equations become linear:

  a·θ̈ − b·α̈ = τ − D_rθ̇
  −b·θ̈ + c·α̈ = d·α − D_pα̇

### 4c. How the code implements it

- **Lines 6–10 — lumped constants.**
  - a = M₁₁ at α = 0, b = −M₁₂ at α = 0, c = M₂₂.
  - d = ½m_p g L_p is the gravity term's slope: d(sin α)/dα = 1 at α = 0.
  - Δ = ac − b² is det(M) at α = 0.
- **Line 12 — total arm damping.** Substituting τ = (k_m/R_m)V_m − (k_m²/R_m)θ̇ shows that back-EMF acts exactly like extra viscous friction. So B_eq = D_r + k_m²/R_m.
- **Lines 14–19 — A and B.** Invert the 2×2 linear mass matrix. Its inverse is (1/Δ)[c b; b a]. Multiplying out:

  θ̈ = [c·(k_m/R_m·V_m − B_eqθ̇) + b·(dα − D_pα̇)] / Δ
  α̈ = [b·(k_m/R_m·V_m − B_eqθ̇) + a·(dα − D_pα̇)] / Δ

  Rows 3–4 of A are the coefficients of α, θ̇, α̇ in these expressions. B holds the coefficients of V_m. Rows 1–2 just say "the derivative of an angle is its velocity".

  **Column 1 of A is zero:** the physics does not depend on where the arm points.
- **Line 21 — C.** The encoders measure θ and α, the first two states. Each row of C picks one state.
- **Line 24 — D.** D = 0 because the voltage does not affect the measured angles instantaneously; it has to integrate twice first.

---

## 5. `furuta_sim_cl.m`: closing the loop on the nonlinear plant

This file simulates "the real pendulum plus our controller" and returns time, states and voltage.

- **Line 14 — the controller.** It computes u = −K(x − x_r) with x_r = [r(t); 0; 0; 0], then clips u to ±V_max.
  - The feedback law is the one designed in Week 10 (doc 06, E2).
  - The clipping, `min(max(u, −Vmax), Vmax)`, models the amplifier saturating. This is a nonlinearity that the linear design ignores.
- **Line 15 — closed-loop dynamics.** This anonymous function is the complete closed loop: at each instant, read x, compute u from the controller, then feed u and the disturbances into the physics.
- **Lines 16–17 — integration.** `ode45` integrates ẋ = f(t, x) forward in time. It uses an adaptive Runge–Kutta (4,5) method: it estimates the error of each step and shrinks the step where the solution changes quickly. The options:
  - `RelTol`/`AbsTol` tighten the accuracy.
  - `MaxStep = 1e-3` stops the solver taking a step so large that it skips straight over a 20 ms disturbance pulse.
- **Lines 18–19 — recover u.** `ode45` only returns states, so the voltage is recomputed at each output time.

**Simplifications here:** the controller is continuous-time, it sees the true state x with no observer, noise or quantisation, and there is no computation delay. Week 11 removes the first of these.

---

## 6. `week9_model_and_openloop.m`: Is the model sensible?

| Lines | What it does | First-principles meaning |
| --- | --- | --- |
| 7–8 | Builds a state-space object `ss(A,B,C,D)` | A container so MATLAB's toolbox functions can operate on the model |
| 13 | `eig(A)` → open-loop poles | Solutions of ẋ = Ax are sums of e^{λt}, where the λ are the eigenvalues of A. Any λ with a positive real part grows, so the system is unstable. Here λ = +10.55 means a lean grows by a factor of e every 95 ms. The λ = 0 pole is the arm, which can rest anywhere |
| 15 | `rank(ctrb(A,B))` | Reachability: can the input steer the state anywhere? This requires rank[B AB A²B A³B] = 4 (doc 06, E4) |
| 16–18 | `rank(obsv(A,C))` | Observability: can the states be reconstructed from the measured outputs? This requires rank[C; CA; CA²; CA³] = 4. With α alone, rank is only 3: the arm angle cannot be deduced from the pendulum angle, because the physics does not depend on θ |
| 19–20 | `tzero` → zeros of θ/V_m | Frequencies the system blocks. The zero at +8.97 rad/s (right half plane) means the arm initially moves the wrong way |
| 24–33 | Release from 2°: `initial` (linear) vs `ode45` on `furuta_nl` | Tests how far the linearisation can be trusted. The two agree to about 15°, then diverge: the real pendulum falls and swings to hanging |
| 35–44 | 1 V, 50 ms pulse: `lsim` vs `ode45` | The response to an input instead of an initial condition |
| 46–56 | Scales each parameter ×0.8 and ×1.2, recomputes the unstable pole | Sensitivity to model uncertainty. J_p and J_r are recomputed, because they depend on the masses and lengths |

---

## 7. `week10_state_feedback.m`: design and test the controller

### §1 (lines 9–14): requirements → limits on the poles

This applies the second-order formulas (doc 06, E10 and E11): overshoot sets ζ, and settling time sets σ = ζωₙ.

### §2 (lines 16–47): candidate controllers

- **Lines 19–23 — pole sets.** Each pole set is built from (E6): the dominant pair −ζωₙ ± jωₙ√(1−ζ²), plus two faster real poles.
- **Line 32 — `place(A,B,p)`.** Finds K so that eig(A − BK) = p. Doc 06 does the same calculation by hand. `place` uses a numerically robust algorithm (Kautsky–Nichols) instead of forming the badly conditioned reachability matrix.
- **Lines 25–26 — `lqr(A,B,Q,R)`.** A different design philosophy: instead of choosing poles, choose weights. LQR minimises J = ∫(xᵀQx + uᵀRu)dt by solving the algebraic Riccati equation.
  - Q = diag(5, 1, 0, 0) penalises arm error 5× more than pendulum lean.
  - R = 1 penalises voltage.
  - The poles fall wherever that trade-off puts them.
- **Line 38 — closed-loop system for a step reference.** From doc 06 (E3), ẋ = (A − BK)x + BK·x_r. With x_r = [r, 0, 0, 0]ᵀ, BK·x_r = B·k₁·r. So the closed-loop "input matrix" for r is `B*K(1)`.
- **Lines 39–43 — metrics.**
  - `stepinfo` measures rise time, settling time and overshoot.
  - US is the undershoot: the dip below zero caused by the RHP zero.
  - `u10` is the **initial** voltage when α = 10°, namely |k₂·α₀|. It is not the peak.
  - `ustep` is the initial voltage jump on a 30° step, |k₁·r|.

### §3 (lines 49–70): the chosen design on the nonlinear plant

The design runs three experiments through `furuta_sim_cl`:

- (a) Release at 10°.
- (b) A 30° arm step at t = 0.2 s.
- (c) A 20 mN·m, 20 ms tap on the pendulum, then a constant 2 mN·m drag on the arm from t = 2 s.

Each disturbance is written as a function of time using logical masks such as `(t >= 0.5 & t < 0.52)`, which equals 1 inside the window and 0 outside.

### §4 (lines 72–81): region of attraction

Increase α₀ by 1° at a time until the controller fails. A test passes if α ends within 1° of upright and never passed 90°. This measures how far beyond the linear model's validity the controller still works.

### §5 (lines 83–91): robustness

Keep K fixed and perturb the plant. If eig(A_k − B_k K) stays in the left half plane, the closed loop is still stable. This checks stability only, not performance.

### §6 (lines 93–113): integral action

**Why it's needed:** with a constant drag τ_d, the steady state of the original loop needs k₁(θ − r)·(k_m/R_m) to balance τ_d. That is only possible with θ ≠ r, so the arm settles off target.

**The fix:** add a state x_i whose derivative is θ − r (line 104, the fifth equation `z(1) - r(t)`). x_i can only stop changing when θ = r exactly. Augmenting A and B (lines 95–96) and placing 5 poles gives Ka.

There is **no anti-windup**. If the voltage saturates for a long time, x_i keeps growing and causes overshoot. It is not triggered in these tests, but it should be noted in the report.

### §7 (lines 115–147): figures

- **Pole map:** plots each design's poles against the ζ ≥ 0.69 rays and the σ ≥ 2 line.
- **Design comparison:** simulates the 4-state closed loop from line 136, with x as the output. The voltage is then reconstructed as u = k₁r − Kx (line 138), which is the same as −K(x − x_r).

---

## 8. `week10_pole_placement_derivation.m`

This file reproduces doc 06 numerically, step by step:

| Lines | Step |
| --- | --- |
| 14–21 | Requirements → ζ, ωₙ → poles |
| 24 | Desired polynomial: `poly(p)` multiplies out the factors (s − pᵢ) |
| 34–44 | Builds the hand-derived coefficient matrix M and open-loop constants (doc 06, E27–E28) |
| 48–52 | **Independent check of the hand algebra.** The characteristic polynomial is linear in K, so poly(A − B·eᵢ) − poly(A) gives column i of M exactly, where eᵢ is a unit gain. The agreement to 10⁻¹¹ proves the hand formulas |
| 57–62 | Solves M·Kᵀ = rhs (coefficient matching) |
| 65–69 | Ackermann's formula: `polyvalm` evaluates Δ_d(A) with matrix powers |
| 72–75 | `place` cross-check, and the eigenvalues of the result |

---

## 9. Assumptions and limitations to state in the report

| Assumption | Where | Effect |
| --- | --- | --- |
| Slender uniform rods | `furuta_params`, `furuta_nl` | Inertias from mL²/12; the pendulum's own spin term is neglected |
| Arm pivots at its centre (J_r = m_rL_r²/12) | `furuta_params` line 16 | **Verify.** End-pivot (/3) moves the stable poles noticeably |
| Viscous friction only | `furuta_nl` | Real bearings also have Coulomb friction (a dead-band) |
| Motor inductance neglected | `furuta_nl` line 14 | Electrical time constant ≪ mechanical, so this is fine |
| Linear model valid for \|α\| ≲ 15° | `furuta_linmodel` | Measured in Week 9 by comparing with the nonlinear model |
| Full state available | `furuta_sim_cl` | Removed in Week 11 by the observer |
| Continuous time, no noise or quantisation | `furuta_sim_cl` | Real controller runs at 1 kHz on 0.18° encoders |
| No integrator anti-windup | `week10_state_feedback` §6 | Matters only under sustained saturation |
| Parameter sweep checks linear stability only | `week9` §4, `week10` §5 | Nonlinear performance under uncertainty is not yet tested |
