# 06: Pole Placement, Worked Step by Step (Lab 10 A2)

This document derives the state-feedback gain K for design **D2** by hand, then checks it two other ways. Every number here is reproduced by [`matlab/week10_pole_placement_derivation.m`](../matlab/week10_pole_placement_derivation.m).

**Result:** K = [k₁, k₂, k₃, k₄] = **[−0.5077, 13.929, −0.6126, 0.7618]**, with control law u = −K(x − [r, 0, 0, 0]ᵀ) and x = [θ, α, θ̇, α̇]ᵀ.

---

## Step 0: Check reachability

Pole placement can put every closed-loop pole anywhere only if the system is reachable. The reachability matrix is

$$
W_c = \begin{bmatrix} B & AB & A^2B & A^3B \end{bmatrix}
$$

From the script: rank(W_c) = 4 and det(W_c) = −7.77 × 10¹⁰ ≠ 0, so the system is **reachable** and all four poles can be placed.

---

## Step 1: Requirements → ζ, ωₙ → pole locations

### 1a. Where the formulas come from

For an underdamped second-order system the unit step response is

$$
y(t) = 1 - \frac{e^{-\sigma t}}{\sqrt{1-\zeta^2}}\sin(\omega_d t + \phi),\qquad \sigma = \zeta\omega_n,\quad \omega_d = \omega_n\sqrt{1-\zeta^2},\quad \phi = \cos^{-1}\zeta
$$

- **Overshoot.** The first peak occurs where dy/dt = 0, at t_p = π/ω_d. Substituting gives

$$
OS = e^{-\zeta\pi/\sqrt{1-\zeta^2}} \;\;\Rightarrow\;\; \zeta = \frac{-\ln(OS)}{\sqrt{\pi^2 + \ln^2(OS)}}
$$

- **2% settling time.** The response stays inside the envelope e^{−σt}/√(1−ζ²). Setting e^{−σt} = 0.02 gives t = ln(50)/σ = 3.91/σ, so

$$
T_s \approx \frac{4}{\zeta\omega_n} = \frac{4}{\sigma}
$$

- **Rise time** (10–90%): t_r ≈ 1.8/ωₙ for ζ ≈ 0.5–0.8. This is an empirical fit.

### 1b. Apply the requirements (doc 03: OS ≤ 5%, T_s ≤ 2.0 s)

| Requirement | Calculation | Constraint |
| --- | --- | --- |
| OS ≤ 5% | ζ = −ln(0.05) / √(π² + ln²(0.05)) = 2.996 / 4.341 | ζ ≥ 0.690 |
| T_s ≤ 2.0 s | σ = 4 / 2.0 | ζωₙ ≥ 2.0 rad/s |
| RHP zero at z = 8.97 rad/s | bandwidth ≲ z/2 | ωₙ ≲ 4.5 rad/s |

**Choose ζ = 0.7 and ωₙ = 4 rad/s:**

$$
\sigma = 0.7 \times 4 = 2.8,\qquad \omega_d = 4\sqrt{1 - 0.49} = 2.8566
$$

$$
s_{1,2} = -2.8 \pm 2.8566j
$$

Predicted performance: T_s = 4/2.8 = 1.43 s, OS = e^{−0.7π/0.714} = 4.60%, t_r = 1.8/4 = 0.45 s.

**Non-dominant poles:** these are placed on the real axis, 4–5× further left than σ, so they barely affect the shape of the response: s₃ = −12 and s₄ = −15. Placing them at −30 and −40 (design D1) needs about 3.4× more voltage; see doc 04.

---

## Step 2: Desired characteristic polynomial

$$
\Delta_d(s) = (s - s_1)(s - s_2)(s + 12)(s + 15)
$$

The complex pair gives (s + σ)² + ω_d² = s² + 2σs + (σ² + ω_d²) = s² + 5.6s + 16. Note that σ² + ω_d² = 7.84 + 8.16 = 16 = ωₙ². The real poles give (s + 12)(s + 15) = s² + 27s + 180. Multiplying out:

$$
\begin{aligned}
\Delta_d(s) &= (s^2 + 5.6s + 16)(s^2 + 27s + 180) \\
&= s^4 + (27 + 5.6)s^3 + (180 + 151.2 + 16)s^2 + (1008 + 432)s + 2880 \\
&= s^4 + 32.6\,s^3 + 347.2\,s^2 + 1440\,s + 2880
\end{aligned}
$$

So the targets are **a₃ = 32.6, a₂ = 347.2, a₁ = 1440, a₀ = 2880**.

---

## Step 3: Closed-loop characteristic polynomial in terms of K

### 3a. Structure of A − BK

A and B have the structure (numbers from doc 02):

$$
A = \begin{bmatrix} 0 & 0 & 1 & 0 \\ 0 & 0 & 0 & 1 \\ 0 & a_{32} & a_{33} & a_{34} \\ 0 & a_{42} & a_{43} & a_{44} \end{bmatrix},\quad
B = \begin{bmatrix} 0 \\ 0 \\ b_3 \\ b_4 \end{bmatrix}
$$

| a₃₂ | a₃₃ | a₃₄ | a₄₂ | a₄₃ | a₄₄ | b₃ | b₄ |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 149.2751 | −17.0068 | −4.9149 | 261.6091 | −16.8091 | −8.6136 | 49.7275 | 49.1493 |

With K = [k₁ k₂ k₃ k₄], only rows 3 and 4 change:

$$
A - BK = \begin{bmatrix} 0 & 0 & 1 & 0 \\ 0 & 0 & 0 & 1 \\ -b_3k_1 & a_{32} - b_3k_2 & a_{33} - b_3k_3 & a_{34} - b_3k_4 \\ -b_4k_1 & a_{42} - b_4k_2 & a_{43} - b_4k_3 & a_{44} - b_4k_4 \end{bmatrix}
= \begin{bmatrix} 0 & I \\ F & G \end{bmatrix}
$$

### 3b. Reduce the 4×4 determinant to a 2×2 one

For a matrix with block form [0 I; F G], det(sI − (A − BK)) = det(s²I − sG − F). Write the shorthand

$$
p_1 = a_{33} - b_3k_3,\; p_2 = a_{34} - b_3k_4,\; p_3 = a_{43} - b_4k_3,\; p_4 = a_{44} - b_4k_4,\; q_1 = a_{32} - b_3k_2,\; q_2 = a_{42} - b_4k_2
$$

$$
s^2I - sG - F = \begin{bmatrix} s^2 - p_1 s + b_3k_1 & -p_2 s - q_1 \\ -p_3 s + b_4k_1 & s^2 - p_4 s - q_2 \end{bmatrix}
$$

### 3c. Expand

$$
\det = (s^2 - p_1s + b_3k_1)(s^2 - p_4s - q_2) - (p_2s + q_1)(p_3s - b_4k_1)
$$

Collecting powers of s:

$$
\begin{aligned}
s^4 &: 1 \\
s^3 &: -(p_1 + p_4) \\
s^2 &: p_1p_4 - p_2p_3 - q_2 + b_3k_1 \\
s^1 &: p_1q_2 - q_1p_3 + k_1(b_4p_2 - b_3p_4) \\
s^0 &: k_1(b_4q_1 - b_3q_2)
\end{aligned}
$$

### 3d. Substitute back. The k·k products cancel

Expanding p₁p₄ − p₂p₃ gives b₃b₄k₃k₄ − b₃b₄k₃k₄ = 0. The same cancellation happens in the s¹ and s⁰ terms, which is always true for a single input. Every coefficient is therefore **linear** in K. Define

$$
\beta_1 = a_{34}b_4 - a_{44}b_3,\qquad \beta_2 = a_{43}b_3 - a_{33}b_4,\qquad \beta_3 = a_{32}b_4 - a_{42}b_3
$$

Then:

$$
\begin{aligned}
c_3 &= -(a_{33} + a_{44}) + b_3k_3 + b_4k_4 \\
c_2 &= (a_{33}a_{44} - a_{34}a_{43} - a_{42}) + b_3k_1 + b_4k_2 + \beta_1k_3 + \beta_2k_4 \\
c_1 &= (a_{33}a_{42} - a_{32}a_{43}) + \beta_1k_1 + \beta_2k_2 + \beta_3k_3 \\
c_0 &= \beta_3k_1
\end{aligned}
$$

### 3e. Numbers

| Quantity | Value |
| --- | --- |
| β₁ = a₃₄b₄ − a₄₄b₃ | 186.7659 |
| β₂ = a₄₃b₃ − a₃₃b₄ | **0** (exactly; see note) |
| β₃ = a₃₂b₄ − a₄₂b₃ | −5672.4083 |
| −(a₃₃ + a₄₄) | 25.6204 |
| a₃₃a₄₄ − a₃₄a₄₃ − a₄₂ | −197.735 |
| a₃₃a₄₂ − a₃₂a₄₃ | −1939.96 |

**Note: why β₂ = 0.** From doc 02, a₄₃ = −bB_eq/Δ, a₃₃ = −cB_eq/Δ, b₃ ∝ c and b₄ ∝ b. So a₄₃b₃ − a₃₃b₄ ∝ −bc + cb = 0. This is a property of the Furuta model structure, not a coincidence of the numbers, and it makes the hand solution sequential.

**Check:** with K = 0 the open-loop polynomial is s⁴ + 25.62s³ − 197.7s² − 1940s + 0. Its roots are 0, −30.05, +10.55 and −6.12, which match doc 02.

---

## Step 4: Coefficient matching

Set each c_i equal to the target a_i from Step 2. Because β₂ = 0, the equations can be solved one at a time, from the bottom up.

**s⁰:** β₃k₁ = 2880

$$
k_1 = \frac{2880}{-5672.4083} = -0.50772
$$

**s¹:** −1939.96 + β₁k₁ + β₃k₃ = 1440

$$
k_3 = \frac{1440 + 1939.96 - 186.7659(-0.50772)}{-5672.4083} = \frac{3474.79}{-5672.4083} = -0.61258
$$

**s²:** −197.735 + b₃k₁ + b₄k₂ + β₁k₃ = 347.2

$$
k_2 = \frac{347.2 + 197.735 - 49.7275(-0.50772) - 186.7659(-0.61258)}{49.1493} = \frac{544.935 + 25.248 + 114.409}{49.1493} = \frac{684.591}{49.1493} = 13.9288
$$

**s³:** 25.6204 + b₃k₃ + b₄k₄ = 32.6

$$
k_4 = \frac{32.6 - 25.6204 - 49.7275(-0.61258)}{49.1493} = \frac{6.9796 + 30.4620}{49.1493} = \frac{37.4416}{49.1493} = 0.76179
$$

$$
\boxed{K = \begin{bmatrix} -0.5077 & 13.929 & -0.6126 & 0.7618 \end{bmatrix}}
$$

Equivalently, in matrix form M Kᵀ = rhs:

$$
\underbrace{\begin{bmatrix} 0 & 0 & b_3 & b_4 \\ b_3 & b_4 & \beta_1 & \beta_2 \\ \beta_1 & \beta_2 & \beta_3 & 0 \\ \beta_3 & 0 & 0 & 0 \end{bmatrix}}_{M}
\begin{bmatrix} k_1 \\ k_2 \\ k_3 \\ k_4 \end{bmatrix}
=
\begin{bmatrix} 32.6 - 25.6204 \\ 347.2 + 197.735 \\ 1440 + 1939.96 \\ 2880 - 0 \end{bmatrix}
=
\begin{bmatrix} 6.980 \\ 544.935 \\ 3379.96 \\ 2880 \end{bmatrix}
$$

---

## Step 5: Cross-check with Ackermann's formula

$$
K = \begin{bmatrix} 0 & 0 & 0 & 1 \end{bmatrix} W_c^{-1}\,\Delta_d(A),\qquad \Delta_d(A) = A^4 + 32.6A^3 + 347.2A^2 + 1440A + 2880I
$$

Result: K = [−0.507721, 13.9288, −0.612577, 0.761793], identical to Step 4. Ackermann is not practical by hand for a 4×4 system, because it needs A⁴ and W_c⁻¹. Use it only as a check. W_c is also poorly conditioned (cond ≈ 5 × 10⁵), so prefer `place` in practice.

---

## Step 6: Verify

| Method | k₁ | k₂ | k₃ | k₄ |
| --- | --- | --- | --- | --- |
| Coefficient matching (Step 4) | −0.507721 | 13.9288 | −0.612577 | 0.761793 |
| Ackermann (Step 5) | −0.507721 | 13.9288 | −0.612577 | 0.761793 |
| MATLAB `place(A, B, p)` | −0.507721 | 13.9288 | −0.612577 | 0.761793 |

- eig(A − BK) = {−15, −12, −2.8 ± 2.8566j}, exactly the requested poles. The largest difference between the methods is 7 × 10⁻¹⁵.
- The closed-loop step response measured on the linear model is T_s = 1.67 s and OS = 4.7% (doc 04). T_s is slower than the predicted 1.43 s because of the RHP zero at +8.97 rad/s and the non-dominant poles. This is why the design must be checked by simulation, not by the 2nd-order formulas alone.

---

## Interpreting the signs

- **k₂ = +13.9 V/rad (pendulum angle).** If the pendulum leans by +α, the arm must be driven under it. This is the dominant gain: 10° of lean gives 2.4 V.
- **k₁ = −0.51 V/rad (arm angle).** The negative sign is correct for a non-minimum-phase plant. To move the arm towards r, the controller first pushes the arm the *opposite* way, tipping the pendulum towards the target. The pendulum loop then carries the arm over. It would be wrong to "fix" this sign.
- **Sanity check from Step 4:** k₁ = a₀/β₃. The sign of k₁ is set entirely by the sign of β₃ (the coupling between gravity and the input). The constant term of Δ_d is always positive for a stable design.

---

## Extending to the integrator design (doc 04 §3)

Augment the state with x_i = ∫(θ − r) dt:

$$
A_a = \begin{bmatrix} A & 0 \\ [1\;0\;0\;0] & 0 \end{bmatrix},\quad B_a = \begin{bmatrix} B \\ 0 \end{bmatrix},\quad \Delta_d(s) = (s^2 + 5.6s + 16)(s + 12)(s + 15)(s + 5)
$$

The same steps apply to a 5×5 system. In practice use `place(Aa, Ba, p)` and verify with eig. The result is K_a = [−1.86, 20.0, −0.985, 1.24, −2.54].
