# 03: Design Requirements (Lab 10 A1)

## 1. Answers to the Lab 10 questions

**Why does the system need to be controlled?**
The upright equilibrium is unstable, with an open-loop pole at +12.09 rad/s (time constant 83 ms). Released at 2°, the pendulum passes 15° in 0.22 s, which is faster than a human can react. Without feedback the upright position cannot be held at all.

**Which signals can we measure?**
θ (motor encoder) and α (pendulum encoder), each with 2048 counts/rev (3.07 mrad resolution). The velocities θ̇ and α̇ are not measured, so 2 sensors cover 4 states. This motivates the observer.

**How can we act on the system?**
Through the motor voltage V_m only, limited to ±10 V. The motor torque τ = (k_m/R_m)(V_m − k_m θ̇) gives a stall torque of about 0.05 N·m at 10 V.

**What are the minimum improvements that justify control?**
The pendulum must stay upright indefinitely, with a stable closed loop, and the arm must go to a commanded angle. Anything less is failure, because the uncontrolled system falls in under 0.3 s.

**How should the system respond to realistic disturbances?**

- A tap on the pendulum must be rejected without falling or saturating for long.
- Constant arm drag (from the encoder cable or friction) must not leave a large arm offset.
- Encoder quantisation must not cause visible chatter in V_m.

**What are the constraints?**

- Input: |V_m| ≤ 10 V.
- States: |α| ≲ 15° for the linear model to stay valid. The controller's region of attraction is larger; see [04_controller_and_observer.md](04_controller_and_observer.md).
- Arm: |θ| ≤ 90°, to limit cable wind-up and stay within a sensible workspace.

## 2. Requirements

| ID | Requirement | Target | Why this value |
| --- | --- | --- | --- |
| R1 | Closed-loop stability | All poles of A − BK in the LHP; balance indefinitely | Basic purpose |
| R2 | Pendulum recovery | From α₀ = 10°: \|α\| < 1° within 1.5 s; no fall | 10° is a realistic hand-release error |
| R3 | Arm step tracking (30°) | 2% settling ≤ 2.5 s; overshoot ≤ 5%; undershoot ≤ 10% | Serving throughput, §4. The undershoot comes from the RHP zero and cannot be avoided |
| R4 | Arm rise time | t_r ≥ 0.3 s (do not go faster) | Avoid exciting liquid slosh and stay below the RHP zero's bandwidth limit, §4 |
| R5 | Actuator | \|V_m\| ≤ 10 V in tests R2, R3, R6 | Conservative limit inside the ±15 V drive range and 18 V motor rating. The earlier 6 V target is dropped: with J_r = /3 it isn't achievable (D-15) |
| R6 | Disturbance: pendulum tap | 20 mN·m for 20 ms: max \|α\| < 15°, recovered within 2 s | Drink stays in the glass, and the linear model stays valid, §4 |
| R7 | Disturbance: arm drag | 2 mN·m constant: steady-state θ error < 2° (with integral action: 0) | About 4% of stall torque, a realistic cable drag |
| R8 | Robustness | R1, R2, R5 still met with ±20% on m_p, L_p, R_m, k_m, D_r, D_p | Parameter uncertainty |
| R9 | Arm excursion | \|θ\| ≤ 90° during R2 and R6 | Cable and workspace limit |

## 3. Converting requirements into pole locations

Use second-order dominant-pole approximations:

$$
\zeta = \frac{-\ln(OS/100)}{\sqrt{\pi^2 + \ln^2(OS/100)}},\qquad
T_s(2\%) \approx \frac{4}{\zeta\omega_n},\qquad
t_r \approx \frac{1.8}{\omega_n}
$$

- OS ≤ 5% gives ζ ≥ 0.69. Choose **ζ = 0.75** for margin.
- T_s ≤ 2.5 s gives ζω_n ≥ 1.6 rad/s.
- The slosh cap and the RHP-zero limit (R4, §4) give ω_n ≲ 4.5 rad/s.
- Choose **ω_n = 3.6 rad/s**: s = −2.7 ± 2.38j. The predicted T_s is 1.48 s, which leaves margin for the zero and the extra poles.
- Place the remaining two poles at 4× and 5× the real part of the dominant pair: −10.8 and −13.5. Faster poles mean higher gains and more voltage (see the comparison in doc 04).

These are Aleksei's choices, adopted as the final design (D-19; doc 04 §3b).

Desired characteristic polynomial (design D4):

$$
\Delta_d(s) = (s^2 + 5.4s + 12.96)(s + 10.8)(s + 13.5)
$$

**Caveat:** the plant has a RHP zero, and the "fast" poles are not very far away. The 2nd-order formulas are therefore only a starting point. Always check the result with `stepinfo` and the nonlinear simulation, then iterate.

## 4. Application and how the requirements follow from it

**Result:** the requirements are derived from a concrete application, a **serving robot arm carrying a drink on a tray mounted on an unactuated (passive) joint**. This is Jack's robotic bartender idea, and it is a real research problem: the *waiter's problem* [Heins & Schoellig 2026; Biagiotti et al. 2023].

The lab rig is a scale model of the motion, not a working bartender. The numbers below are assumptions chosen to be reasonable and are stated openly.

**Why a passive joint?** Fewer actuators reduce weight, cost and energy use, and help fault tolerance [Arai]. Heins & Schoellig get the benefits of pendular motion from a tray with no actuated joints of its own, which reduces sliding and sloshing.

**The weak point, which you should expect a marker to ask about:** their tray *hangs*, which is naturally stable. Ours is inverted, and so needs active control. The justification is that the load sits above the arm, so the arm can reach under or around things and a glass can be taken from above. It's a reasonable scenario, not an established design.

### From the application to each requirement

| Requirement | Derivation | Assumptions |
| --- | --- | --- |
| **Tilt \|α\| ≤ 15°** | A level drink spills at tilt arctan(freeboard / radius) = arctan(10 / 35) = 15.9°. This also keeps the linear model accurate (sin α ≈ α within 1.2%) | Glass radius 35 mm, 10 mm freeboard |
| **Speed cap ω_n ≲ 4.5 rad/s** | Avoid exciting slosh. First mode of a cylinder: ω² = (1.841 g/R) tanh(1.841 H/R) [Reclari et al. 2014], giving 22.7 rad/s (3.6 Hz). Keep the dominant poles about 5× below | Same glass; H ≥ R, so tanh ≈ 1; the 5× separation is our rule |
| **Settling floor about 1.3 s** | T_s ≈ 4/(ζω_n) = 4/(0.7 × 4.5). The RHP zero (+10.3 rad/s, so z/2 ≈ 5.2 rad/s) gives a similar limit | ζ = 0.7 |
| **Settling ≤ 2.5 s** | A commercial robot bar makes 80+ drinks per hour [Makr Shakr], i.e. 45 s per drink. Suppose settling takes about a quarter of that (11 s) over 4 arm moves per drink: 2.8 s per move. Rounded down to 2.5 s | 4 moves and the 25% share are assumptions |
| **Overshoot ≤ 5%** | Don't swing past the serving position towards the customer | Design choice |
| **Disturbance: tap** | A customer bumping the tray or taking a glass | Size chosen as a firm bump |
| **±20% parameters** | Parameter error. This is about ±5 g on the pendulum, so it doesn't cover a glass being added or removed | — |

### Limitations of this framing

- **Effective tilt:** the liquid responds to the tilt and to acceleration, tan(tilt) ≈ a/g. Only α is used here, so the spill limit is approximate.
- **Scale:** the rig is small. By dynamic similarity, time scales with √(length), so a taller real tray would be slower by that factor. The 2.5 s is applied directly at rig scale, so it is a target for the demonstrator, not a scaled-up specification.
- **Payload:** the pendulum is a uniform rod, with no tray or glass modelled. A real tray and glass would be top-heavy. In a scratch study, the final gains stay up with up to 20 g at the tip and fall at 30 g (LOGBOOK, 2026-11-04). An Australian schooner glass weighs 300–330 g empty (Jack's figure; source still needed), more than twice the 141 g at the tip at which gravity at 15° reaches the motor's stall torque. The glass figures therefore describe the application, not a payload on the rig. The report states this in Section II-C.

### Other applications considered

| Idea | Physics link | Verdict |
| --- | --- | --- |
| **Serving arm / bartender** | Inverted load on a passive joint, under-actuated, with real literature | **Chosen.** It gives a physical basis for tilt, speed and settling |
| Self-balancing vehicle (Segway) | Very close, already cited [Pujol et al.] | **Good backup.** Still needs a comfort or response figure for settling |
| Golf swing | Real link: a double pendulum with a passive wrist, derived by Lagrange [Chen et al. 2007; White 2006] | **No.** It's a fast, one-shot energy transfer through a *hanging* position, with nothing to regulate at an unstable equilibrium. It relates to swing-up, not to our LTI design |
| ML / RL benchmark | The device is a common test-bed | **No (agreeing with Jack).** A benchmark's pass mark isn't derived from physics, and it gives no real-world reason for the limit |
| Mixer | A rotating arm with a swinging load | **No.** A mixer wants motion, so nothing needs holding at an unstable point |
| Weather station | Wind gusts resemble taps | **No.** A rigid mast would be simpler; nothing justifies a hinge |

