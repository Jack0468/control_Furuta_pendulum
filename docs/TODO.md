# TODO: What Is Still Open

**Due: 11:59 pm Friday 6 November 2026.** Last updated 2026-11-04.

Tick items off here as they are done. When an item closes a logbook issue (I-xx) or decision (D-xx), also update [LOGBOOK.md](LOGBOOK.md).

## Human ideas to improve this report

Jack's review notes, 2026-11-04, with what was done about each.

- [x] We want to consolidate the information to only use the required content that is specfically from this course. e.g. we do not need to include LQR. and Kalman filters can probably be binned from report because it is not directly in the course and is not part of the assignment spec.
  **Done:** LQR is out of the design comparison and Kalman is out of the report. LQR stays only in the literature review, which the rubric marks, and in `week10_state_feedback.m`.
- [x] we need to directly explain our the versions for each design. e.g. what actually is D1 and what design choices did it make specfically.
  **Done:** Section IV-B has one item per design: the choice it tests, its poles, its gains and the outcome.
- [x] we need to explain the design criteria more in depth.
  **Done:** Section III-C has one item per criterion, derived from an aim and converted to a pole region.
- [x] also make a git ignored doc with the assignment marking criteria which I gave you earlier and should be in the chat memory.
  **Done:** `references/course/marking_criteria.md`.
- [x] why do we have Luenberger observer ? is that distinctly different from a regular observer ? is it necessary for the scope of this project ?
  **Answer:** it's the same thing: the standard state observer, named after its inventor. The course says "observer", so the report does too.
- [x] for the observer section: we need to include the analystical derivation of the poles for the observer.
  **Done:** Section IV-C derives L from the characteristic polynomial, and `week11_observer.m` checks it. Full steps are in doc 04 §4.
- [x] we should explicitly explain the disturbances in which we model responses to in this project.
  **Done:** Section II-C lists each one with its cause, size and what it tests.
- [x] what does the 30° arm step (centre) mean explicitly can you mention this in the report.
  **Done:** Section V-A and the caption of the overview figure.
- [x] can you explain figure 5 in more detail.
  **Done:** Section V-C goes through each panel with measured numbers. The figure itself is now in the Appendix.

**Current state:** `run_all` is done and the figures, docs and report numbers all match the final design (published damping, Aleksei's poles, observer −100…−130). What's left is mainly the people-only items and rewriting the blue prose. The refresh is merged to `main` (PR #2). Jack's review notes below are applied in the working copy, not yet committed.

"Who" is a suggestion: **Jack**, **Aleksei**, **Team** (both), or **Claude** (AI-assisted; declare this in the report).

---

## 1. Confirm with Aleksei

| Done | ID | Task | Who | Notes |
| --- | --- | --- | --- | --- |
| [ ] | — | **Move to one report.** Aleksei is still writing in his own copy, and his abstract, 6-page note and duplicate System Model remain there | Team | His second draft's new content is merged into `report/main.tex`. Further edits should go there, or they'll need merging by hand |
| [ ] | I-09 | **Get Aleksei's design script into the repo,** or confirm his abstract's results aren't used. Check his gain signs against his report's α convention | Aleksei | His `.slx` files need A, B, C and K from a script that isn't committed. Details in the LOGBOOK, 2026-11-04 |
| [ ] | D-25 | **Check the $z/2$ bandwidth bound in Skogestad & Postlethwaite (2005), Aleksei's source, and add the section number** | Aleksei | Fri 6 Nov | Justifies the speed criterion in Section III-C. Åström & Murray was dropped in favour of his citation |
| [ ] | D-25 | **Read Baltazar et al. (2024) and confirm the 1.68 s settling time** | Aleksei | Fri 6 Nov | His source for the 1.5 s recovery criterion; marked orange |
| [ ] | D-25 | **Tell Aleksei his third draft is merged** and that his Overleaf copy has unresolved git conflict markers | Jack | Fri 6 Nov | Edit `report/main.tex` from now on, not his copy |
| [ ] | — | Look over the regenerated figures in `figures/` and the draft PDF | Jack | `python report/build.py --open` |

## 2. Refresh and publish

| Done | ID | Task | Who | Notes |
| --- | --- | --- | --- | --- |
| [x] | — | Run `run_all` (3–7 min; keep the computer awake, as sleep pauses it) | Claude | Done 2026-11-04. Log in `scratch/` |
| [x] | — | Refresh every result in the docs, README and the report from the new log | Claude | Done 2026-11-04, including the hand derivation in doc 06 |
| [x] | I-08 | Record the final ripple and settling time | Claude | 0.71° ripple, inside the ±0.6° band; T_s 1.38 s |
| [x] | — | Commit, push and merge the refresh, so Aleksei can see everything | Jack | Merged as PR #2, 2026-11-04 |
| [ ] | — | Commit Jack's review changes, and bring them into Overleaf | Jack | Overleaf doesn't sync with the repo, so hold off editing the changed sections there until they're copied across |

## 3. Things only a person can do

| Done | ID | Task | Who | By | Notes |
| --- | --- | --- | --- | --- | --- |
| [ ] | — | Read the sources tagged in the report's reference list, starting with Hamza 2019 | Team | Wed 4 Nov | The brief rejects unverified references; [doc 10 §1](10_literature_review.md) shows what was only an abstract or record |
| [x] | — | Read Acosta 2010 and confirm the 0.75 rad LQR claim and the methods listed in the Introduction | Aleksei | Wed 4 Nov | Full text blocked for automated access. `--final` hides the orange mark, so fix or remove the sentence first **Done 2026-11-06:** full text read (papers folder). Sec. 3.2 surveys energy shaping, forwarding, feedback linearisation; Fig. 6 gives 0.75 rad (LQR), 0.82 rad (energy shaping), 1.45 rad, on hardware. Orange mark removed |
| [x] | — | Give a source for the rocket-landing claim in the Introduction, or drop it | Aleksei | Wed 4 Nov | No source in either draft **Done 2026-11-06:** Pei & Rothhaar (NASA SLS pole-cart) is about *launch* vehicles, so the sentence now says launch vehicles. Venue and year still orange |
| [ ] | — | Check Aleksei's MATEC paper: it's about a *tilted* Furuta pendulum, so does it support what he cites it for? | Aleksei | Wed 4 Nov | Only needed if it's cited: his report draft doesn't cite it. The site blocked automated access |
| [x] | I-03 | Find a source for m_r = 0.095 kg, ideally the QUBE-Servo 2 workbook | Jack | Wed 4 Nov | J_r depends on it. The TU Delft sheet was unreachable **Done 2026-11-06:** no source found; checked instead against a solid aluminium bar, L_r × 20 × 20 mm at 2700 kg/m³ = 0.092 kg (Section II-B, Table I 'Al bar') |
| [ ] | — | Check the copper temperature coefficient (0.393 %/°C) against IEC 60028 or a textbook | Jack | Fri 6 Nov | Marked orange: only a secondary copy of the standard was seen. It justifies the ±20% range in Section II-C |
| [ ] | — | Confirm the 6-page limit on Canvas | Jack | Wed 4 Nov | Our copy of the brief says at most 8 pages; the rubric gives no limit. The report is built to 6, which fits either way |
| [x] | — | Confirm the arm's ±90° cable limit, or state it as an assumption | Team | Wed 4 Nov | Both of you assumed it **Done 2026-11-06:** now a workspace limit we chose; Acosta's rig uses a slip ring for full rotation |
| [x] | — | Get the AI-citation rules from Canvas or your tutor, then write the declaration | Team | Thu 5 Nov | Searched every course PDF: no rule stated, only "ask an LLM, but be critical" (Lecture 1, p. 32) and slides crediting "source: ChatGPT" **Done 2026-11-06:** Lecture 1-2 has only 'ask an LLM agent, but be critical' (p. 32); the brief says AI agents follow the Lecture 1 guidelines. Declaration drafted in the Acknowledgment, orange until checked against Canvas |
| [ ] | — | Confirm `Template-Latex.zip` matches the one on Canvas | Jack | Wed 4 Nov | |
| [ ] | I-05 | Only if you cite textbooks: check chapter numbers against your edition | Team | Thu 5 Nov | The report draft cites none |

## 4. Report (IEEE LaTeX, max 6 pages not counting references and the appendix; build with `python report/build.py`)

| Done | Task | Who | By | Source material |
| --- | --- | --- | --- | --- |
| [ ] | **Rewrite all blue prose in your own words.** Equations, tables and data can stay | Team | Thu 5 Nov | `report/main.tex` |
| [ ] | §1 Abstract (about 200 words, up to 5 keywords) and §7 Conclusions | Team | Thu 5 Nov | LOGBOOK |
| [ ] | §2 Introduction (literature review, justify choices, report structure) | Team | Thu 5 Nov | [Doc 10 §2](10_literature_review.md) |
| [ ] | §3 System Model | Team | Wed 4 Nov | Docs 02, 08, 10 §3 |
| [ ] | §4 Problem Definition | Team | Wed 4 Nov | Docs 02 §3, 03 §4 |
| [ ] | §5 Controller Design | Aleksei (proposed) | Thu 5 Nov | Docs 04, 06, 09 |
| [ ] | §6 Numerical Validations | Jack (proposed) | Thu 5 Nov | Doc 05 |
| [ ] | Stay within the 6-page body: check with `--final`, which reports it. The body fills page 6 exactly, so the rewrite can't add any length. The AI declaration sits with the references on page 7: ask whether that counts; check notation, including `b` used for both the encoder offset and a model constant; every figure is discussed in the text | Team | Thu 5 Nov | |
| [ ] | Put the reference list in first-cited order, as IEEE style expects | Team | Thu 5 Nov | `report/main.tex` |

## 5. Before submission

| Done | Task | Who | By |
| --- | --- | --- | --- |
| [ ] | Clone the repo fresh, run `run_all`, and check the numbers and figures match the report | Team | Thu 5 Nov |
| [ ] | Build with `python report/build.py --final --package` for the final PDF and MATLAB zip | Jack | Fri 6 Nov |
| [ ] | Check the PDF: machine-readable, body ≤ 6 pages, IEEE format, all seven sections | Team | Fri 6 Nov |
| [ ] | Proofread | Team | Fri 6 Nov |
| [ ] | Submit the report PDF and MATLAB files on Canvas | Jack | **Fri 6 Nov** |

---

## Done (for reference)

Closed items, newest first. Details are in the [LOGBOOK](LOGBOOK.md).

- [x] Aleksei's third draft merged, his words first in Sections I–III (D-25), 2026-11-06
- [x] Bartender framing dropped; criteria justified from the model, the motor and the literature (D-24), 2026-11-06
- [x] Speed limit now set by the 10 V limit, with the iteration stated; payload claims removed and the ±20% justified from sources (D-23), 2026-11-06
- [x] Aleksei's third draft merged (actuator limitation, aim and operating point, requirements summary), 2026-11-06
- [x] Report restructured to a 6-page body plus references and a 3-figure appendix; tray limitation added (D-22), 2026-11-04
- [x] Aleksei's second draft merged into the report (stacking step, arm-modelling elements, grouped parameter table), 2026-11-04
- [x] Jack's review notes applied to the report; `week11_observer.m` extended; marking criteria doc added, 2026-11-04
- [x] `run_all` to `figures/`, then the report and docs refreshed from the log; doc 06 redone for D4, 2026-11-04
- [x] Aleksei's report sections merged into `report/main.tex` (D-20), 2026-11-04
- [x] Aleksei's Simulink run with our gains: agrees with our code on the shared test, 2026-11-04
- [x] Aleksei's poles adopted in the code (D-19), 2026-11-03
- [x] I-10: settling limit derived from the serving-arm application (doc 03 §4), pending your acceptance, 2026-11-03
- [x] I-02: Monte Carlo failures explained: weak motor and short arm reduce loop gain, 2026-11-03
- [x] I-06: anti-windup tested at the edge of falling: no practical effect, 2026-11-03
- [x] I-11: pendulum spin term restored in the model and equations, 2026-11-03
- [x] I-12: motor data found: CL40 16705 matches R_m and k_m, rated 18 V, 0.54 A, 2026-11-03
- [x] 2-D Kalman Q sweep: pendulum noise dominates, 2026-11-03
- [x] Disturbance-estimating Kalman filter: not needed if Aleksei's poles meet the tap limit; listed as future work, 2026-11-03
- [x] Report-quality figures: `furuta_savefig.m`, IEEE widths, 300 dpi, 2026-11-03
- [x] Published damping values adopted (D-16), 2026-11-03
- [x] Doc 01 and doc 03 updated; requirements justified, 2026-11-03
- [x] MATLAB packaging added to `build.py`, 2026-11-03
- [x] Report first draft, compile script, literature research, margins (docs 10, `week12_margins.m`), 2026-11-03
- [x] Rubric received and coverage mapped (doc 10 §4); LaTeX template located (I-07), 2026-11-03
- [x] Arm geometry: case A (D-13); settling limit 2.5 s (D-14), 2026-11-03
- [x] Kalman filter derivation and trade-off study (doc 09), 2026-10-29
- [x] Observer-based control at 1 kHz, validation V1–V7, `run_all.m`, 2026-10-29
- [x] Type-1 servo fix (D-07); faster observer (D-10), 2026-10-29
- [x] Encoder selection and datasheet noise model (doc 08), 2026-10-29
- [x] Tutor approval of the Furuta pendulum (D-01), 2026-10-29
- [x] Equations of motion derived with references (doc 02 §2); code explained (doc 07), 2026-10-29
- [x] Model, requirements, state feedback, hand derivation of K (docs 01–06), 2026-10-15
