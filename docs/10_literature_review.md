# 10: Research for the Report's Opening Sections

Research for the Abstract, Introduction and System Model, mapped to the marking rubric. **Last updated 2026-11-03.**

The brief says AI-generated references that have not been independently verified are not acceptable. So §1 states exactly how far each source was checked. **Claude's checks don't count as yours:** open every paper you cite before submission.

---

## 1. Sources and how far each was checked

- **Read:** Claude read the relevant text, from a local PDF in `references/papers/` (git-ignored) or a fetched page.
- **Record:** only the bibliographic record (Crossref) and/or abstract were seen. **Don't state findings beyond the abstract until you've read it.**

| # | Source | Checked | Use it for |
| --- | --- | --- | --- |
| 1 | K. Furuta, M. Yamakita, S. Kobayashi, "Swing-up control of inverted pendulum using pseudo-state feedback," *Proc. IMechE Part I*, vol. 206, no. 4, pp. 263–269, 1992. [doi:10.1243/PIME_PROC_1992_206_341_02](https://doi.org/10.1243/PIME_PROC_1992_206_341_02) | Record | Origin of the rotary pendulum work |
| 2 | M. Gäfvert, "Modelling the Furuta Pendulum," Tech. Rep. TFRT-7574, Lund Inst. of Technology, 1998. [PDF](https://lucris.lub.lu.se/ws/files/4453844/8727127.pdf) | **Read** | Euler–Lagrange derivation; arm inertia; friction models; "parameters must be measured or identified" |
| 3 | B. S. Cazzolato, Z. Prime, "On the Dynamics of the Furuta Pendulum," *J. Control Sci. Eng.*, vol. 2011, Art. 528341. [doi:10.1155/2011/528341](https://doi.org/10.1155/2011/528341) | Record (publisher blocked automated access; open access for you) | Full-inertia model; what simplified models neglect |
| 4 | J. Á. Acosta, "Furuta's Pendulum: A Conservative Nonlinear Model for Theory and Practise," *Math. Probl. Eng.*, vol. 2010, Art. 742894. [doi:10.1155/2010/742894](https://doi.org/10.1155/2010/742894) | Record + abstract (**Aleksei's source**; full text blocked for automated access) | Modelling approaches; his LQR and 0.75 rad claim, once a person has read it |
| 5 | A. Wadi, J.-H. Lee, L. Romdhane, "Dynamic Analysis of the Tilted Furuta Pendulum," *MATEC Web Conf.*, vol. 104, Art. 02011, 2017. [doi:10.1051/matecconf/201710402011](https://doi.org/10.1051/matecconf/201710402011) | Record (**Aleksei's source**; site blocked access) | Equations of motion, if Aleksei confirms it fits: its subject is a *tilted* variant |
| 6 | M. F. Hamza et al., "Current development on using Rotary Inverted Pendulum as a benchmark for testing linear and nonlinear control algorithms," *Mech. Syst. Signal Process.*, vol. 116, pp. 347–369, 2019. [doi:10.1016/j.ymssp.2018.06.054](https://doi.org/10.1016/j.ymssp.2018.06.054) | Record + abstract | **Main survey**: control objectives and controller classes |
| 7 | O. Boubaker, "The Inverted Pendulum Benchmark in Nonlinear Control Theory: A Survey," *Int. J. Adv. Robot. Syst.*, vol. 10, no. 5, 2013. [doi:10.5772/55058](https://doi.org/10.5772/55058) | Record | Benchmark context |
| 8 | K. J. Åström, K. Furuta, "Swinging up a pendulum by energy control," *Automatica*, vol. 36, no. 2, pp. 287–295, 2000. [doi:10.1016/S0005-1098(99)00140-5](https://doi.org/10.1016/S0005-1098(99)00140-5) | Record; the [1996 IFAC version](https://www.control.utoronto.ca/~broucke/ece1653s/Intro/ast_fur96.pdf) **read** | Swing-up by energy control, then catch with a stabilising controller |
| 9 | G. Pujol, L. Acho, A. Nápoles, V. Pérez-García, "Experimental realization of the Furuta pendulum to emulate the Segway motion," [arXiv:1405.1834](https://arxiv.org/abs/1405.1834), 2014. | **Read** (intro) | Under-actuated systems context; Segway link; LMI-H∞ |
| 10 | M. Antonio-Cruz et al., "Modeling, Computer Aided Design, and Construction of a Furuta Pendulum Test-Bed," *Research in Computing Science*, vol. 83, pp. 133–144, 2014. [PDF](https://www.rcs.cic.ipn.mx/2014_83/Modeling,%20Computer%20Aided%20Design,%20and%20Construction%20of%20a%20Furuta%20Pendulum%20Test-Bed.pdf) | **Read** (intro) | Lagrange derivation; "popular benchmark and educational device"; small, buildable hardware |
| 11 | J. Xu, Y. Tan, X. Chen, "Robust Tracking Control for Nonlinear Systems: Performance optimization via extremum seeking," [arXiv:2304.00138](https://arxiv.org/abs/2304.00138), 2023. | **Read** (Section V) | **QUBE-Servo 2 parameter table**, equations (citing the Quanser workbook) |
| 12 | R. H. S. de Souza et al., "State-feedback control of a reaction-wheel inverted pendulum prototype," *Front. Control Eng.*, vol. 7, Art. 1905949, 2026. [doi:10.3389/fcteg.2026.1905949](https://doi.org/10.3389/fcteg.2026.1905949) | **Read** (abstract, via a fetch tool) | Pole placement and LQR "equivalent" in hardware; **ESP32 at 1 ms sampling** (different plant) |
| 13 | M. Izutsu, Y. Pan, K. Furuta, "Swing-up of Furuta Pendulum by Nonlinear Sliding Mode Control," *SICE JCMSI*, vol. 1, no. 1, pp. 12–17, 2008. [doi:10.9746/jcmsi.1.12](https://doi.org/10.9746/jcmsi.1.12) | Record | Sliding-mode example |
| 14 | S. Jung, J. T. Wen, "Nonlinear Model Predictive Control for the Swing-Up of a Rotary Inverted Pendulum," *J. Dyn. Sys., Meas., Control*, vol. 126, no. 3, pp. 666–673, 2004. [doi:10.1115/1.1789541](https://doi.org/10.1115/1.1789541) | Record | Predictive-control example |
| 15 | T. F. Tang, S. H. Chong, K. K. Pang, "Stabilisation of a rotary inverted pendulum system with double-PID and LQR control: experimental verification," *Int. J. Automation and Control*, vol. 14, no. 1, 2020. | Record (title and venue) | Linear stabilisation in experiment. Removed from the report on 2026-11-06, as it was unread |
| 16 | M. Gäfvert, J. Svensson, K. J. Åström, "Friction and friction compensation in the Furuta pendulum," *Proc. European Control Conf.*, pp. 3154–3159, 1999. [doi:10.23919/ECC.1999.7099812](https://doi.org/10.23919/ECC.1999.7099812) | Record | Friction as a limitation |
| 17 | J. C. Doyle, "Guaranteed margins for LQG regulators," *IEEE Trans. Autom. Control*, vol. 23, no. 4, pp. 756–757, 1978. [doi:10.1109/TAC.1978.1101812](https://doi.org/10.1109/TAC.1978.1101812) | Record; PDF downloaded (scanned text only partly checked) | Observer-based loops have no guaranteed margins |
| 18 | D. G. Luenberger, "Observing the State of a Linear System," *IEEE Trans. Mil. Electron.*, vol. 8, no. 2, pp. 74–80, 1964. [doi:10.1109/TME.1964.4323124](https://doi.org/10.1109/TME.1964.4323124) | Record | Origin of the observer. No longer cited in the report |
| 19 | P. R. Bélanger et al., "Estimation of Angular Velocity and Acceleration from Shaft-Encoder Measurements," *Int. J. Robot. Res.*, vol. 17, no. 11, pp. 1225–1233, 1998. [doi:10.1177/027836499801701107](https://doi.org/10.1177/027836499801701107) | Record | Velocity from encoders |
| 20 | Avago/Broadcom HEDS-5540 and US Digital E5/EM1 datasheets | **Read** | Sensor model (doc 08) |
| 21 | A. Heins, A. P. Schoellig, "Robotic Nonprehensile Object Transportation with a Hanging Tray," [arXiv:2606.10039](https://arxiv.org/abs/2606.10039), 2026. | **Read** (abstract) | Waiter's problem; a pendulum tray reduces sliding and sloshing with no actuated tray joint. **Removed from the report 2026-11-06 (D-24).** |
| 22 | L. Biagiotti, D. Chiaravalli, R. Zanella, C. Melchiorri, "Optimal Feed-Forward Control for Robotic Transportation of Solid and Liquid Materials via Nonprehensile Grasp," [arXiv:2306.14212](https://arxiv.org/abs/2306.14212), 2023. | **Read** (abstract) | Carrying objects on a tray; sloshing and sliding. **Removed from the report 2026-11-06 (D-24).** |
| 23 | H. Arai, S. Tachi, "Position Control of a Manipulator with Passive Joints Using Dynamic Coupling," *IEEE Trans. Robot. Autom.*, vol. 7, no. 4, pp. 528–534, 1991. [Abstract](https://staff.aist.go.jp/h.arai/abstracts/tra91ab.htm); motivation from the author's [project page](https://staff.aist.go.jp/h.arai/uam_e.html) | **Read** (abstract, page) | Passive joints: lower weight, cost and energy; fault tolerance |
| 24 | M. Reclari et al., "Surface wave dynamics in orbital shaken cylindrical containers," *Phys. Fluids*, vol. 26, Art. 052104, 2014. [arXiv:1412.0919](https://arxiv.org/abs/1412.0919) | **Read** (eq. 3) | Slosh frequency of a cylinder. **Removed from the report 2026-11-06 (D-24).** |
| 25 | Makr Shakr, [Toni product page](https://www.makrshakr.com/toni) | **Read** | "80+ drinks/hour". A company claim: press figures vary. **Removed from the report 2026-11-06 (D-24).** |
| 26 | Allied Motion, [CL Series datasheet](https://www.alliedmotion.com/wp-content/uploads/documents/Allied_Motion_Datasheet-CLSeries_20171002.pdf), 2017, CL40 model 16705 | **Read** | Rated current and torque, inductance |
| 27 | Quanser, [QUBE-Servo 2 USB documentation](https://docs.quanser.com/quarc/documentation/qube_servo2_usb.html) | **Read** | ±15 V drive range, ±3 A current sense |
| 28 | S. Barrios Valero, "Design and Implementation of a Furuta Pendulum Device for Benchmarking Non-Linear Control Methods," Bachelor's thesis, Univ. Zaragoza, 2016. [Record](https://zaguan.unizar.es/record/61249) | **Read** (§5.1) (**Aleksei's source**) | Pole placement in simulation: three poles, torque input, plot starts just above 0.1 rad. The 6° comes from that plot, not the text |
| 29 | C. Baltazar, R. Gonzales, E. Manzano, "Furuta Pendulum Prototype Control: PID and State Feedback," *IEEE URUCON*, pp. 1–5, 2024. [doi:10.1109/URUCON63440.2024.10850206](https://doi.org/10.1109/URUCON63440.2024.10850206) | Record (**Aleksei's source**) | Not cited in the report |
| 30 | T. Räsänen, V.-P. Pyrhönen, "State feedback control of a rotary inverted pendulum," *Proc. Automaatiopäivät 23*, Oulu, 2019, pp. 52–59 | **Not found** in one search (**Aleksei's source**) | Not cited in the report. Aleksei to supply a link if it's needed |

**Citation errors found while checking.** Crossref settles these, so use the versions above:

- Åström & Furuta is pp. **287–295**. Lund's own record says 278–285, which is wrong.
- Furuta et al. is vol. 206, no. **4**. Wikipedia says no. 6.
- The earlier reference list in doc 01 needs no change for these, but doc 02's textbook chapter numbers are still unverified (I-05).

**Rejected:** Tahir et al. 2020 (BEEI). A search summary described it as a Furuta pendulum study, but the paper itself models a cart-pole, so it doesn't support a Furuta claim.

---

## 2. Material for the Introduction

The rubric gives one point each for: context, why control is needed, a literature review, the effectiveness of existing solutions, using the literature to justify your choices, report structure, and clarity.

**Context.** The rotary inverted pendulum is under-actuated, nonlinear and unstable, and has long been used to test control algorithms [6]. Under-actuated systems have more degrees of freedom than inputs, as with spacecraft, underwater vehicles and mobile robots, and new stabilisation methods are often validated on benchmarks like this one [9]. The Segway is a commercial relative of the same balancing problem [9]. Your annotation fits here: the device is small and can be built in a lab [10], so it is a practical test-bed.

**Why control is needed.** Upright is an unstable equilibrium. Our model has a pole at +12.09 rad/s, and a pendulum released at 2° passes 15° in 0.22 s.

> **A correction to your annotation.** You wrote that the pendulum will never reach its upward equilibrium "if it does not have constant control effort". Two different things are mixed there:
> - **Reaching** upright from hanging needs energy put in: that's the swing-up problem [8].
> - **Staying** upright needs continuous *feedback*, not constant *effort*. At exact equilibrium the required voltage is zero (ū = 0), because gravity exerts no torque. The voltage only responds to deviations, but any deviation grows if left alone.

**Your second annotation makes a strong framing.** The system is highly nonlinear, yet an LTI approximation can control it within a region. That is a good thesis for the report: it shows how linear design solves a useful region of a harder problem, and it gives a reason to report the region of attraction (24°).

**Existing control approaches** (the survey in [6] groups the objectives as swing-up, stabilisation, switching and tracking):

| Approach | Example | What it offers | Why we didn't choose it |
| --- | --- | --- | --- |
| Energy-based swing-up, then a stabilising controller | [8] | Global: brings the pendulum up from hanging | Outside our aim of balancing near upright; a natural future extension |
| Sliding mode | [13] | Nonlinear, and insensitive to some uncertainty | Outside the unit; [13] addresses swing-up |
| Nonlinear MPC | [14] | Handles large motions and constraints | Heavier computation; outside the unit |
| H∞ / LMI | [9] | Designed-in robustness | Outside the unit |
| LQR / PID in experiment | [15] | Simple linear stabilisation | Close to our approach; LQR is included as a comparison |
| Pole placement vs LQR | [12] (reaction wheel) | Found equivalent in hardware on that plant | Supports using pole placement |

**Justifying your choices with this literature.** The brief requires LTI, observer-based state feedback. Since the aim is balance near upright, not swing-up, the linear controllers used in [12, 15] suit the task, and [8] shows stabilisation is a separate stage from swing-up. Encoders give angles but not velocities, which motivates a state observer over differentiation [19].

**Gap to fill before writing:** [6] is the key survey, and only its abstract has been seen. Read it first. Its reference list should also let you strengthen the table above.

---

## 3. Material for the System Model

**Modelling approach.** Euler–Lagrange is the standard route [2, 10]. Gäfvert's report is an accessible, fully readable source. Cazzolato & Prime [3] derive the model with a full inertia tensor, per [10].

**Parameters: what the sources actually support**

| Parameter | Our value | Evidence | Status |
| --- | --- | --- | --- |
| R_m, k_m, L_r, L_p, m_p | 8.4 Ω, 0.042, 0.085 m, 0.129 m, 0.024 kg | [11] Table I matches exactly | **Supported** (secondary source; the original is the Quanser workbook) |
| m_r | 0.095 kg | A search excerpt of a TU Delft sheet; the site was unreachable and [11] doesn't list it | Open that sheet or the workbook |
| J_r | m_rL_r²/3 = 2.29 × 10⁻⁴ | **See below** | Stated assumption (D-13) |
| D_r, D_p | 0.0005, 0.0001 | [11] | **Supported** (changed on 2026-11-03 to the published values) |
| V_max | ±10 V | [27] gives a ±15 V drive range, [26] an 18 V rating | **Conservative design limit**, inside both |
| Encoders | 2048 counts/rev | Datasheet parts (doc 08); Quanser docs confirm 4× quadrature only | Supported for the chosen parts |

**The J_r evidence is mixed, and the report should say so.**

- **For case A:** Gäfvert computes the arm as a homogeneous bar about its end: 2T_a = ⅓m_al_a²φ̇² ([2], eq. 9). A search excerpt of a Lehigh QUBE lab sheet (not opened: the link now returns 404) also gives J_r = m_rr²/3 = 2.2879 × 10⁻⁴. Aleksei's model uses it too.
- **Against:** [11] lists "J_r = 2.3060 × 10⁻⁴" for the QUBE-Servo 2, which is exactly J_r + m_pL_r² with `/12`. So a published QUBE model corresponds to `/12`. I told you `/12` "looks like an error": geometrically it doesn't fit a uniform bar reaching the joint, but it does match a published value, so that was too strong.
- **What it means for us:** keep case A as a stated assumption and treat the difference as model uncertainty. Our nominal design stays stable on the `/12` value (below).

**Published values vs our nominal design** (`week12_margins.m`):

| Plant | Stable? | 10° release | Tap, max \|α\| |
| --- | --- | --- | --- |
| Nominal (J_r `/3`, D_r 0.0005, D_p 0.0001 [11]) | Yes | Recovers | 14.6° |
| J_r `/12` [11] | Yes | Recovers | 8.3° |
| D_r 0.001, D_p 0.00005 (Aleksei's earlier values) | Yes | Recovers | 13.4° |
| D_r 0.0015, D_p 0.0005 | Yes, near marginal (max \|z\| 0.9996) | Slow wobble: 0.92° at the end, 1.0 V RMS | 12.7° |

So the design stays stable on all of them, but **higher damping pushes it close to marginal**, and damping is the least certain parameter. Gäfvert also notes significant real friction and that physically sound parameters come from measurement or identification [2].

**Limitations to discuss** (rubric: "limitations with respect to the real-world system"):

- Viscous friction only: [2, 16] show Coulomb friction and stiction matter on real hardware.
- Motor inductance neglected: L/R = 1.16 mH / 8.4 Ω = 0.14 ms for the matching motor [26], far faster than the mechanics.
- Arm treated as a uniform bar; rotor inertia (4 × 10⁻⁶ kg·m² [26], under 2% of J_r) and flexibility ignored.
- The pendulum spin term is now included, following [2] and [11].

**Your actuator and sensor annotations**, with evidence:

- **Motor voltage and current thresholds.** The CL40 16705 [26] matches our R_m and k_m exactly, and is rated 18 V, 0.54 A, 22 mN·m. No opened source says the QUBE uses this motor, so word it as "a motor with matching constants". Peak current in simulation is about 1.1 A: that's about twice the continuous rating, but it lasts only a fraction of a second, and it's well below the 2.1 A stall current [26] and inside the ±3 A sense range [27].
- **Encoder noise profile.** Doc 08: q = 3.07 mrad, σ = 0.886 mrad, from the datasheet resolution and error terms.
- **Microcontroller clock and sampling.** The loop needs roughly 65 floating-point operations per sample, under 1% of a 1 ms period on an STM32F4 (my estimate, not measured). The closest hardware evidence is [12], which runs an ESP32 at 1 ms on a reaction-wheel pendulum. Our delay margin is 35 ms, far above the 1 ms sample time.
- **Velocities (your "d/dθ, d/dφ" note).** These can't simply be differentiated: one count per sample is 176 deg/s of noise. That's why the observer is needed (doc 08 §4, RMS error 30 vs 2.8 deg/s).

---

## 4. Rubric coverage

Your note on the brief says the report must document the process in order and justify every decision in the code. The rubric rewards exactly this ("how they were chosen", "iterative"), and the LOGBOOK decision register gives you that story.

| Section (marks) | Criterion | Status |
| --- | --- | --- |
| Abstract (3) | Direct, method, key results; up to 5 keywords; about 200 words | Draft in `report/` |
| Introduction (7) | All seven criteria | §2 above; read [6] first |
| System Model (20) | ODE model, limitations, parameters, uncertainties and disturbances **modelled**, actuators, sensors and noise | Ready, except damping and rated current |
| Problem Definition (20) | Aims, operating point, **criteria derived from aims**, linear model, states/I/O, measurement model | **Derivation now in [doc 03 §4](03_design_requirements.md)** from the serving-arm application |
| Controller Design (25) | Reachability, observability | Done |
| | **Stability ranges of controller parameters** | **New: done** (`week12_margins.m`) |
| | Gains, how chosen, actuator limits | Done |
| | **Gain margins with Bode or Nyquist** | **New: done** (−4.6 / +16.6 dB, PM 36°) |
| | Observer; error stability; eigenvalues vs controller | Done (7.4–9.6× the fastest controller pole), with an analytical derivation of L |
| Validations (20) | Nominal on nonlinear model; disturbance, uncertainty, noise | Done |
| | **Linear vs nonlinear differences** (from the criteria text) | **New: done** |
| | Criteria met or failure discussed; control signals; estimation error | Done; R6 passes by 0.4° and R8 is partial, both discussed |
| | Figures clearly formatted | Done: `furuta_savefig.m` sizes figures for IEEE columns at 300 dpi |
| Conclusion (5) | Context, findings, justified future work | Draft in `report/` |
