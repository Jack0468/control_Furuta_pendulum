# 06: Pole Placement, Worked Step by Step (Lab 10 A2)

This document derives the state-feedback gain K for design **D2** by hand. Every equation is numbered as (E1), (E2), and so on. Each one says where it comes from: a definition, an earlier equation, a theorem, or a textbook result. Every number is reproduced by [`matlab/week10_pole_placement_derivation.m`](../matlab/week10_pole_placement_derivation.m).

**Result:** K = [k₁, k₂, k₃, k₄] = **[−0.5077, 13.929, −0.6126, 0.7618]**

---

## Notation

### States, input and output

| Symbol | Meaning | Unit |
| --- | --- | --- |
| θ | Arm angle | rad |
| α | Pendulum angle from upright (α = 0 is upright) | rad |
| θ̇, α̇ | Arm and pendulum angular velocities | rad/s |
| x = [θ, α, θ̇, α̇]ᵀ | State vector | — |
| u = V_m | Motor voltage (the only input) | V |
| r | Desired arm angle (reference) | rad |
| K = [k₁ k₂ k₃ k₄] | State-feedback gain row vector; k₁ multiplies θ, k₂ multiplies α, k₃ multiplies θ̇, k₄ multiplies α̇ | V/rad, V·s/rad |

### Physical parameters (doc 02 §4)

| Symbol | Meaning | Value |
| --- | --- | --- |
| m_p, L_p, J_p | Pendulum mass, full length, inertia about its centre of mass | 0.024 kg, 0.129 m, 3.33 × 10⁻⁵ kg·m² |
| L_r, J_r | Arm length, arm inertia about the motor axis | 0.085 m, 5.72 × 10⁻⁵ kg·m² |
| R_m, k_m | Motor resistance, motor torque/back-EMF constant | 8.4 Ω, 0.042 N·m/A |
| D_r, D_p | Viscous damping at the arm and pendulum joints | 0.0015, 0.0005 N·m·s/rad |
| g | Gravity | 9.81 m/s² |

### Lumped constants (from the linearisation, doc 02 §3)

| Symbol | Definition | Physical meaning | Value |
| --- | --- | --- | --- |
| a | J_r + m_p L_r² | Arm inertia, including the pendulum mass at the arm tip | 2.3060 × 10⁻⁴ kg·m² |
| b | ½ m_p L_p L_r | Inertial coupling between arm and pendulum | 1.3158 × 10⁻⁴ kg·m² |
| c | J_p + ¼ m_p L_p² | Pendulum inertia about its pivot (parallel-axis theorem) | 1.3313 × 10⁻⁴ kg·m² |
| d | ½ m_p g L_p | Gravity torque per radian of lean | 1.5186 × 10⁻² N·m/rad |
| Δ | ac − b² | Determinant of the linearised mass matrix (always > 0) | 1.3386 × 10⁻⁸ (kg·m²)² |
| B_eq | D_r + k_m²/R_m | Total arm damping: friction plus motor back-EMF | 1.71 × 10⁻³ N·m·s/rad |

### Control-design symbols

| Symbol | Meaning |
| --- | --- |
| ζ, ωₙ | Damping ratio and natural frequency of the dominant pole pair |
| σ, ω_d | σ = ζωₙ (decay rate) and ω_d = ωₙ√(1−ζ²) (damped frequency) |
| OS, T_s, t_r | Percentage overshoot, 2% settling time, 10–90% rise time |
| s₁ … s₄ | Desired closed-loop pole locations |
| Δ_d(s) | Desired characteristic polynomial, with coefficients a₃, a₂, a₁, a₀ |
| Δ_cl(s) | Actual closed-loop characteristic polynomial, with coefficients c₃, c₂, c₁, c₀ |
| W_c | Reachability (controllability) matrix |

---

## Step 0: The closed-loop system and why reachability matters

### 0a. The plant

The linearised model from doc 02 §3 is

$$
\dot x = Ax + Bu \tag{E1}
$$

**Where it comes from:** linearising the nonlinear equations of motion about the upright equilibrium x̄ = 0, ū = 0 (doc 02, Lagrangian model with sin α ≈ α and cos α ≈ 1).

### 0b. The control law

$$
u = -K\,(x - x_r),\qquad x_r = \begin{bmatrix} r & 0 & 0 & 0 \end{bmatrix}^T \tag{E2}
$$

**Where it comes from:** this is a design choice, standard full-state feedback measured from a target state. x_r means "arm at r, pendulum upright, nothing moving". It is a valid equilibrium because the first column of A is zero (θ does not appear in the dynamics, since the arm can rest at any angle), so A x_r = 0.

### 0c. The closed-loop system

Substitute (E2) into (E1):

$$
\dot x = Ax - BK(x - x_r) = (A - BK)\,x + BK\,x_r \tag{E3}
$$

**Where it comes from:** direct substitution. The stability and transient behaviour are set by the matrix **A − BK**. The term BKx_r only moves the equilibrium. Pole placement therefore means choosing K so that the eigenvalues of A − BK are where we want them.

### 0d. Reachability test

$$
W_c = \begin{bmatrix} B & AB & A^2B & A^3B \end{bmatrix} \tag{E4}
$$

**Where it comes from:** the pole-placement theorem (Ogata, *Modern Control Engineering*, Ch. 10; Åström & Murray, *Feedback Systems*, Ch. 7). The eigenvalues of A − BK can be placed **anywhere** if and only if W_c has full rank n (here n = 4).

**Result:** rank(W_c) = 4 and det(W_c) = −7.77 × 10¹⁰ ≠ 0, so the system is reachable and design can proceed.

---

## Step 1: Requirements → ζ, ωₙ → pole locations

### 1a. The second-order model behind the formulas

We want the closed loop to behave like a standard second-order system:

$$
G(s) = \frac{\omega_n^2}{s^2 + 2\zeta\omega_n s + \omega_n^2} \tag{E5}
$$

**Where it comes from:** this is the standard prototype for second-order systems (Ogata Ch. 5; Franklin, Powell & Emami-Naeini, *Feedback Control of Dynamic Systems*, Ch. 3). A 4th-order closed loop behaves approximately like (E5) when two poles (the **dominant pair**) are much closer to the imaginary axis than the others. The faster poles' contributions decay quickly, so the slow pair sets the shape of the response.

The poles of (E5) are the roots of s² + 2ζωₙs + ωₙ² = 0. By the quadratic formula, for ζ < 1:

$$
s_{1,2} = -\zeta\omega_n \pm j\,\omega_n\sqrt{1-\zeta^2} = -\sigma \pm j\omega_d \tag{E6}
$$

**Where it comes from:** the quadratic formula applied to the denominator of (E5). σ = ζωₙ is the real part, which sets the decay rate. ω_d = ωₙ√(1−ζ²) is the imaginary part, which sets the oscillation frequency.

The unit step response of (E5) is found by taking the inverse Laplace transform of G(s)/s, using partial fractions:

$$
y(t) = 1 - \frac{e^{-\sigma t}}{\sqrt{1-\zeta^2}}\,\sin(\omega_d t + \phi),\qquad \phi = \cos^{-1}\zeta \tag{E7}
$$

**Where it comes from:** the standard derivation in Ogata §5-3. The sinusoid comes from the complex pole pair, and the factor e^{−σt} from their real part.

### 1b. Overshoot → ζ

The peak occurs where dy/dt = 0. Differentiating (E7) gives dy/dt ∝ e^{−σt} sin(ω_d t), which is first zero (after t = 0) at

$$
t_p = \frac{\pi}{\omega_d} \tag{E8}
$$

Substituting t_p into (E7), with sin(π + φ) = −sin φ = −√(1−ζ²):

$$
y(t_p) = 1 + e^{-\zeta\pi/\sqrt{1-\zeta^2}} \;\;\Rightarrow\;\; OS = e^{-\zeta\pi/\sqrt{1-\zeta^2}} \tag{E9}
$$

**Where it comes from:** (E7) evaluated at (E8). OS depends on ζ only.

Solving (E9) for ζ. Take logs: ln(OS) = −ζπ/√(1−ζ²). Square both sides and rearrange:

$$
\zeta = \frac{-\ln(OS)}{\sqrt{\pi^2 + \ln^2(OS)}} \tag{E10}
$$

**Where it comes from:** algebraic inversion of (E9). Here OS is a fraction, e.g. 5% = 0.05.

### 1c. Settling time → σ

The response (E7) always lies within the envelope 1 ± e^{−σt}/√(1−ζ²). The 2% settling time is when that envelope falls to 2%. Ignoring the 1/√(1−ζ²) factor, which is close to 1 for moderate ζ:

$$
e^{-\sigma T_s} = 0.02 \;\Rightarrow\; T_s = \frac{\ln 50}{\sigma} = \frac{3.91}{\sigma} \approx \frac{4}{\zeta\omega_n} \tag{E11}
$$

**Where it comes from:** the decaying envelope of (E7). This is the standard "4/σ" rule (Ogata §5-3).

### 1d. Rise time → ωₙ

$$
t_r \approx \frac{1.8}{\omega_n} \tag{E12}
$$

**Where it comes from:** an empirical fit to (E7) for ζ ≈ 0.5 (Franklin, Powell & Emami-Naeini §3.4). It has no exact closed form. It is used here only as an estimate.

### 1e. Upper limit from the right-half-plane zero

$$
\omega_{bw} \lesssim \frac{z}{2},\qquad z = +8.97\ \text{rad/s} \tag{E13}
$$

**Where it comes from:** a fundamental limitation of non-minimum-phase systems (Åström & Murray, *Feedback Systems*, Ch. 14; Skogestad & Postlethwaite, *Multivariable Feedback Control*, Ch. 5). The transfer function θ(s)/V_m(s) has a zero at s = +8.97 (doc 02 §5). Making the arm loop much faster than about z/2 causes large undershoot, where the arm first moves the wrong way. With ζ = 0.7, the closed-loop bandwidth is about ωₙ, so this means ωₙ ≲ 4.5 rad/s.

### 1f. Apply the requirements (from doc 03: OS ≤ 5%, T_s ≤ 2.0 s)

| Requirement | Equation used | Calculation | Constraint |
| --- | --- | --- | --- |
| OS ≤ 5% | (E10) | ζ = −ln(0.05) / √(π² + ln²(0.05)) = 2.996 / 4.341 | ζ ≥ 0.690 |
| T_s ≤ 2.0 s | (E11) | σ ≥ 4 / 2.0 | ζωₙ ≥ 2.0 rad/s |
| RHP zero | (E13) | 8.97 / 2 | ωₙ ≲ 4.5 rad/s |

**Choose ζ = 0.7** (just above 0.690, for a little margin) **and ωₙ = 4 rad/s**, which satisfies both 0.7 × 4 = 2.8 ≥ 2.0 and 4 ≤ 4.5. Using (E6):

$$
\sigma = 0.7 \times 4 = 2.8,\qquad \omega_d = 4\sqrt{1 - 0.7^2} = 4 \times 0.71414 = 2.8566
$$

$$
s_{1,2} = -2.8 \pm 2.8566j \tag{E14}
$$

The predicted performance, from (E9), (E11) and (E12), is OS = 4.60%, T_s = 1.43 s and t_r = 0.45 s.

### 1g. The other two poles

The system has 4 states, so 4 poles must be chosen. The other two are placed on the real axis, well to the left of the dominant pair:

$$
s_3 = -12,\qquad s_4 = -15 \tag{E15}
$$

**Where they come from:** this is a design choice, using the dominant-pole rule of thumb that non-dominant poles should be at least 3–5× further left than σ. Here 12/2.8 = 4.3 and 15/2.8 = 5.4. Pushing them further left (e.g. −30 and −40 in design D1) makes the response more ideal, but it needs much larger gains and more voltage (doc 04 §2). The two values differ slightly so that `place` does not have to handle repeated poles.

---

## Step 2: Desired characteristic polynomial

The characteristic polynomial is the polynomial whose roots are the poles. For the poles in (E14) and (E15):

$$
\Delta_d(s) = (s - s_1)(s - s_2)(s - s_3)(s - s_4) \tag{E16}
$$

**Where it comes from:** the definition of a monic polynomial in terms of its roots (factor theorem).

Multiplying the complex-conjugate pair (E6) first removes the j terms:

$$
(s + \sigma - j\omega_d)(s + \sigma + j\omega_d) = (s+\sigma)^2 + \omega_d^2 = s^2 + 2\sigma s + (\sigma^2 + \omega_d^2) \tag{E17}
$$

**Where it comes from:** the difference of squares, (p − jq)(p + jq) = p² + q². Note that σ² + ω_d² = ζ²ωₙ² + ωₙ²(1−ζ²) = ωₙ², so (E17) is exactly the denominator of (E5): s² + 2ζωₙs + ωₙ².

With the numbers: 2σ = 5.6 and σ² + ω_d² = 7.84 + 8.16 = 16 = ωₙ². The real poles give (s + 12)(s + 15) = s² + 27s + 180. Multiplying the two quadratics term by term:

$$
\begin{aligned}
\Delta_d(s) &= (s^2 + 5.6s + 16)(s^2 + 27s + 180) \\
&= s^4 + (27 + 5.6)\,s^3 + (180 + 5.6\cdot27 + 16)\,s^2 + (5.6\cdot180 + 16\cdot27)\,s + 16\cdot180 \\
&= s^4 + 32.6\,s^3 + 347.2\,s^2 + 1440\,s + 2880
\end{aligned} \tag{E18}
$$

**Targets:** a₃ = 32.6, a₂ = 347.2, a₁ = 1440, a₀ = 2880.

---

## Step 3: Closed-loop characteristic polynomial in terms of K

### 3a. Definition

$$
\Delta_{cl}(s) = \det\big(sI - (A - BK)\big) \tag{E19}
$$

**Where it comes from:** the definition of the characteristic polynomial of a matrix. Its roots are the eigenvalues of A − BK, which by (E3) are the closed-loop poles.

### 3b. Structure of A and B

From doc 02 §3, A and B have the form

$$
A = \begin{bmatrix} 0 & 0 & 1 & 0 \\ 0 & 0 & 0 & 1 \\ 0 & a_{32} & a_{33} & a_{34} \\ 0 & a_{42} & a_{43} & a_{44} \end{bmatrix},\qquad
B = \begin{bmatrix} 0 \\ 0 \\ b_3 \\ b_4 \end{bmatrix} \tag{E20}
$$

**Where it comes from:**

- **Rows 1–2** are the kinematic identities d(θ)/dt = θ̇ and d(α)/dt = α̇. They come from the choice of state vector, not from physics.
- **Rows 3–4** come from solving the two linearised equations of motion for θ̈ and α̈ (doc 02 §3).
- **Column 1 is zero** because θ itself does not appear in the dynamics.
- **B has zeros in rows 1–2** because the voltage affects accelerations, not the angles directly.

Each entry in terms of the physical constants, and its value:

| Entry | Formula (doc 02 §3) | Physical meaning | Value |
| --- | --- | --- | --- |
| a₃₂ | bd/Δ | Gravity on the pendulum accelerating the arm | 149.2751 |
| a₃₃ | −cB_eq/Δ | Arm damping acting on the arm | −17.0068 |
| a₃₄ | −bD_p/Δ | Pendulum damping coupled to the arm | −4.9149 |
| a₄₂ | ad/Δ | Gravity tipping the pendulum (causes the instability) | 261.6091 |
| a₄₃ | −bB_eq/Δ | Arm damping coupled to the pendulum | −16.8091 |
| a₄₄ | −aD_p/Δ | Pendulum damping acting on the pendulum | −8.6136 |
| b₃ | c k_m / (R_m Δ) | Voltage → arm acceleration | 49.7275 |
| b₄ | b k_m / (R_m Δ) | Voltage → pendulum acceleration | 49.1493 |

### 3c. Form A − BK

BK is the 4×4 matrix with b_i k_j in row i, column j. B has zeros in rows 1–2, so only rows 3–4 of A change:

$$
A - BK = \begin{bmatrix} 0 & 0 & 1 & 0 \\ 0 & 0 & 0 & 1 \\ -b_3k_1 & a_{32} - b_3k_2 & a_{33} - b_3k_3 & a_{34} - b_3k_4 \\ -b_4k_1 & a_{42} - b_4k_2 & a_{43} - b_4k_3 & a_{44} - b_4k_4 \end{bmatrix}
= \begin{bmatrix} 0 & I \\ F & G \end{bmatrix} \tag{E21}
$$

Here F and G are the 2×2 lower-left and lower-right blocks. The 0 and I blocks are the kinematic rows from (E20).

**Where it comes from:** matrix subtraction using (E20). The column vector B times the row vector K is an outer product.

### 3d. Reduce the 4×4 determinant to 2×2

$$
\det\!\left(sI_4 - \begin{bmatrix} 0 & I \\ F & G \end{bmatrix}\right) = \det\begin{bmatrix} sI & -I \\ -F & sI - G \end{bmatrix} = \det\left(s^2 I - sG - F\right) \tag{E22}
$$

**Where it comes from:** the block (Schur-complement) determinant formula det[P Q; R S] = det(P)·det(S − RP⁻¹Q), with P = sI, Q = −I, R = −F and S = sI − G. This gives det(sI)·det(sI − G − F/s) = s²·det(sI − G − F/s). Multiplying a 2×2 matrix by s multiplies its determinant by s², so this equals det(s²I − sG − F).

To keep the algebra short, define

$$
p_1 = a_{33} - b_3k_3,\;\; p_2 = a_{34} - b_3k_4,\;\; p_3 = a_{43} - b_4k_3,\;\; p_4 = a_{44} - b_4k_4,\;\; q_1 = a_{32} - b_3k_2,\;\; q_2 = a_{42} - b_4k_2 \tag{E23}
$$

These are just the entries of G and F from (E21). Then

$$
s^2I - sG - F = \begin{bmatrix} s^2 - p_1 s + b_3k_1 & -p_2 s - q_1 \\ -p_3 s + b_4k_1 & s^2 - p_4 s - q_2 \end{bmatrix} \tag{E24}
$$

**Where it comes from:** substituting G = [p₁ p₂; p₃ p₄] and F = [−b₃k₁ q₁; −b₄k₁ q₂] from (E21) and (E23).

### 3e. Expand the 2×2 determinant

Using det[w x; y z] = wz − xy on (E24):

$$
\Delta_{cl}(s) = (s^2 - p_1s + b_3k_1)(s^2 - p_4s - q_2) - (p_2s + q_1)(p_3s - b_4k_1) \tag{E25}
$$

Multiplying out and collecting powers of s:

$$
\begin{aligned}
s^4 &: 1 \\
s^3 &: -(p_1 + p_4) \\
s^2 &: p_1p_4 - p_2p_3 - q_2 + b_3k_1 \\
s^1 &: p_1q_2 - q_1p_3 + k_1(b_4p_2 - b_3p_4) \\
s^0 &: k_1(b_4q_1 - b_3q_2)
\end{aligned} \tag{E26}
$$

**Where it comes from:** polynomial multiplication of (E25).

### 3f. Substitute back: the k·k products cancel

Substitute (E23) into (E26). Some terms look as if they will produce products of gains, but they cancel. For example, in the s² term:

$$
p_1p_4 - p_2p_3 = (a_{33} - b_3k_3)(a_{44} - b_4k_4) - (a_{34} - b_3k_4)(a_{43} - b_4k_3)
$$

The k₃k₄ terms are +b₃b₄k₃k₄ − b₃b₄k₃k₄ = 0. The same cancellation happens in the s¹ and s⁰ terms.

**Why:** for a single-input system, BK has rank 1, and the characteristic polynomial of A − BK is always linear (affine) in K. This is what makes pole placement a *linear* problem.

After cancelling, collect the coefficients of each gain. Three combinations appear repeatedly, so define

$$
\beta_1 = a_{34}b_4 - a_{44}b_3,\qquad \beta_2 = a_{43}b_3 - a_{33}b_4,\qquad \beta_3 = a_{32}b_4 - a_{42}b_3 \tag{E27}
$$

Then the closed-loop coefficients are

$$
\boxed{\begin{aligned}
c_3 &= -(a_{33} + a_{44}) + b_3k_3 + b_4k_4 \\
c_2 &= (a_{33}a_{44} - a_{34}a_{43} - a_{42}) + b_3k_1 + b_4k_2 + \beta_1k_3 + \beta_2k_4 \\
c_1 &= (a_{33}a_{42} - a_{32}a_{43}) + \beta_1k_1 + \beta_2k_2 + \beta_3k_3 \\
c_0 &= \beta_3k_1
\end{aligned}} \tag{E28}
$$

so that Δ_cl(s) = s⁴ + c₃s³ + c₂s² + c₁s + c₀.

**Where it comes from:** (E26) with (E23) substituted, the k·k terms cancelled, and the result grouped by gain. The script checks (E28) numerically: computing `poly(A − B*K)` for each unit gain vector reproduces the same coefficients to 10⁻¹¹.

### 3g. The constants in physical terms

Substituting the table formulas from §3b into (E27) and (E28), and using ac − b² = Δ, everything simplifies:

| Quantity | Simplifies to | Value | Meaning |
| --- | --- | --- | --- |
| β₁ | D_p k_m / (R_m Δ) | 186.7659 | Pendulum damping × motor gain |
| β₂ | (−bB_eq·c + cB_eq·b) k_m / (R_m Δ²) = **0** | 0 | Cancels exactly; see below |
| β₃ | −d k_m / (R_m Δ) | −5672.4083 | Gravity × motor gain; always negative |
| −(a₃₃ + a₄₄) | (cB_eq + aD_p)/Δ | 25.6204 | Total open-loop damping |
| a₃₃a₄₄ − a₃₄a₄₃ − a₄₂ | (B_eq D_p − ad)/Δ | −197.735 | Damping product minus gravity stiffness |
| a₃₃a₄₂ − a₃₂a₄₃ | −d B_eq / Δ | −1939.96 | Gravity × arm damping |

**Why β₂ = 0:** a₄₃b₃ and a₃₃b₄ both equal −bcB_eq k_m/(R_mΔ²). This is a structural property of the Furuta model, not a numerical coincidence. As a result k₂ drops out of c₁ and k₄ drops out of c₂, which makes the hand solution sequential in Step 4.

**Open-loop check:** set K = 0 in (E28). This gives Δ_cl(s) = s⁴ + 25.62s³ − 197.7s² − 1940s + 0. Its roots are 0, −30.05, +10.55 and −6.12, which match the open-loop poles in doc 02 §5. The +10.55 pole confirms that the upright position is unstable without control.

---

## Step 4: Coefficient matching

We want Δ_cl(s) = Δ_d(s). Two monic polynomials of the same degree are identical if and only if their coefficients are equal. Therefore:

$$
c_3 = a_3,\qquad c_2 = a_2,\qquad c_1 = a_1,\qquad c_0 = a_0 \tag{E29}
$$

**Where it comes from:** equating coefficients in (E28) and (E18). This is the standard "direct substitution" or "coefficient matching" pole-placement method (Ogata §10-2, method 2). It gives 4 linear equations for 4 unknowns.

With β₂ = 0, solve them from the bottom up.

**s⁰ term** (c₀ = a₀), using (E28):

$$
\beta_3 k_1 = 2880 \;\Rightarrow\; k_1 = \frac{2880}{-5672.4083} = -0.50772 \tag{E30}
$$

**s¹ term** (c₁ = a₁). With β₂ = 0, k₂ drops out, so only k₃ is unknown:

$$
-1939.96 + \beta_1 k_1 + \beta_3 k_3 = 1440 \;\Rightarrow\; k_3 = \frac{1440 + 1939.96 - 186.7659 \times (-0.50772)}{-5672.4083} = \frac{3474.79}{-5672.4083} = -0.61258 \tag{E31}
$$

**s² term** (c₂ = a₂). With β₂ = 0, k₄ drops out, so only k₂ is unknown:

$$
-197.735 + b_3k_1 + b_4k_2 + \beta_1k_3 = 347.2 \;\Rightarrow\; k_2 = \frac{347.2 + 197.735 + 25.248 + 114.409}{49.1493} = \frac{684.591}{49.1493} = 13.9288 \tag{E32}
$$

Here −b₃k₁ = −49.7275 × (−0.50772) = +25.248 and −β₁k₃ = −186.7659 × (−0.61258) = +114.409.

**s³ term** (c₃ = a₃):

$$
25.6204 + b_3k_3 + b_4k_4 = 32.6 \;\Rightarrow\; k_4 = \frac{32.6 - 25.6204 + 30.462}{49.1493} = \frac{37.4416}{49.1493} = 0.76179 \tag{E33}
$$

Here −b₃k₃ = −49.7275 × (−0.61258) = +30.462.

$$
\boxed{K = \begin{bmatrix} -0.5077 & 13.929 & -0.6126 & 0.7618 \end{bmatrix}} \tag{E34}
$$

The same equations in matrix form, M Kᵀ = rhs, which is what the script solves:

$$
\underbrace{\begin{bmatrix} 0 & 0 & b_3 & b_4 \\ b_3 & b_4 & \beta_1 & \beta_2 \\ \beta_1 & \beta_2 & \beta_3 & 0 \\ \beta_3 & 0 & 0 & 0 \end{bmatrix}}_{M}
\begin{bmatrix} k_1 \\ k_2 \\ k_3 \\ k_4 \end{bmatrix}
=
\begin{bmatrix} a_3 - 25.6204 \\ a_2 + 197.735 \\ a_1 + 1939.96 \\ a_0 \end{bmatrix}
=
\begin{bmatrix} 6.980 \\ 544.935 \\ 3379.96 \\ 2880 \end{bmatrix} \tag{E35}
$$

**Where it comes from:** (E29) rearranged, with the gain coefficients from (E28) in M and the open-loop constants moved to the right-hand side.

**A closed-form result worth noting.** Combining (E30) with β₃ from §3g:

$$
k_1 = -\frac{a_0 R_m \Delta}{d\,k_m} = -\frac{\omega_n^2\, s_3 s_4\, R_m \Delta}{d\,k_m} \tag{E36}
$$

**Where it comes from:** a₀ is the product of all four desired poles, ωₙ² × 12 × 15. So the arm-angle gain is always negative, and it grows with ωₙ² and with how fast the extra poles are placed.

---

## Step 5: Cross-check with Ackermann's formula

$$
K = \begin{bmatrix} 0 & 0 & 0 & 1 \end{bmatrix} W_c^{-1}\, \Delta_d(A),\qquad \Delta_d(A) = A^4 + 32.6A^3 + 347.2A^2 + 1440A + 2880I \tag{E37}
$$

**Where it comes from:** Ackermann's formula (Ogata §10-2; Franklin, Powell & Emami-Naeini §7.5). It is derived by transforming the system into controllable canonical form and applying the Cayley–Hamilton theorem: every matrix satisfies its own characteristic equation. Δ_d(A) means substituting the matrix A for s in (E18). W_c is the reachability matrix from (E4).

**Result:** K = [−0.507721, 13.9288, −0.612577, 0.761793], identical to (E34).

Ackermann needs A⁴ and W_c⁻¹, so it is not practical by hand for a 4×4 system. Use it only as a check. W_c is also poorly conditioned (cond ≈ 5 × 10⁵), so numerically `place` is preferred.

---

## Step 6: Verification

| Method | Equation | k₁ | k₂ | k₃ | k₄ |
| --- | --- | --- | --- | --- | --- |
| Coefficient matching | (E30)–(E33) | −0.507721 | 13.9288 | −0.612577 | 0.761793 |
| Ackermann | (E37) | −0.507721 | 13.9288 | −0.612577 | 0.761793 |
| MATLAB `place(A, B, p)` | numerical | −0.507721 | 13.9288 | −0.612577 | 0.761793 |

- **Poles:** eig(A − BK) = {−15, −12, −2.8 ± 2.8566j}, exactly the poles requested in (E14) and (E15). The methods differ by at most 7 × 10⁻¹⁵.
- **Predicted vs measured response:** on the linear model the step response gives T_s = 1.67 s and OS = 4.7% (doc 04). T_s is slower than the 1.43 s predicted by (E11). The difference comes from two effects that (E5) leaves out: the RHP zero at +8.97 rad/s (E13), and the non-dominant poles in (E15), which are only 4–5× faster. This is why the second-order formulas are a starting point, and the design is always confirmed by simulation.

---

## Interpreting the gains

- **k₂ = +13.9 V/rad (pendulum angle).** When the pendulum leans by +α, the controller drives the arm under it, like balancing a broom on a hand. This is the largest gain: a 10° lean gives 13.9 × 0.1745 = 2.4 V.
- **k₁ = −0.51 V/rad (arm angle).** The sign is negative for every stable design, by (E36), because β₃ < 0. Physically, to move the arm towards r the controller first pushes the arm the *opposite* way. That tips the pendulum towards the target, and the pendulum loop then carries the arm over. This is the non-minimum-phase behaviour from (E13). Do not "fix" this sign.
- **k₃, k₄ (velocity gains)** add damping. They cannot be measured directly, which is why the Week 11 observer is needed.

---

## Extending to the integrator design (doc 04 §3)

Add an integrator state x_i, defined by

$$
\dot x_i = \theta - r \tag{E38}
$$

**Where it comes from:** a design choice. Integral action makes the steady-state arm error zero under a constant disturbance torque, because at steady state ẋ_i = 0 forces θ = r.

The augmented system and desired polynomial are

$$
A_a = \begin{bmatrix} A & 0 \\ [1\;0\;0\;0] & 0 \end{bmatrix},\quad B_a = \begin{bmatrix} B \\ 0 \end{bmatrix},\quad \Delta_d(s) = (s^2 + 5.6s + 16)(s + 12)(s + 15)(s + 5) \tag{E39}
$$

**Where it comes from:** (E1) with (E38) appended as a fifth state equation. The extra pole at −5 is chosen near the dominant pair, so the integrator acts within about 1 s without dominating the response.

The same Steps 3–6 apply to this 5×5 system. In practice use `place(Aa, Ba, p)` and verify with eig. The result is K_a = [−1.86, 20.0, −0.985, 1.24, −2.54].

---

## References

- K. Ogata, *Modern Control Engineering*, 5th ed. Ch. 5 (second-order transient response), Ch. 10 (pole placement, Ackermann's formula).
- G. F. Franklin, J. D. Powell and A. Emami-Naeini, *Feedback Control of Dynamic Systems*. Ch. 3 (time-domain specifications), Ch. 7 (state-space design).
- K. J. Åström and R. M. Murray, *Feedback Systems*, 2nd ed. Ch. 7 (state feedback, reachability), Ch. 14 (fundamental limitations, RHP zeros).
- S. Skogestad and I. Postlethwaite, *Multivariable Feedback Control*, 2nd ed. Ch. 5 (limitations from RHP zeros and poles).
- Doc 02 of this repo for the model derivation and the values of A and B.
