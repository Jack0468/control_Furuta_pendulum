#!/usr/bin/env python3
"""Draw the Furuta pendulum geometry for the report appendix (figures/furuta_diagram.png).

Usage (from anywhere):  python report/furuta_diagram.py

Sign convention, as in the report (Section II-A) and docs/02 section 1:
  theta  arm angle, positive anticlockwise seen from above.
  alpha  pendulum angle from upright, positive leaning AGAINST positive arm rotation
         (clockwise when viewed from the motor looking out along the arm).
Lengths are drawn to the scale of Table I (L_r = 85 mm, L_p = 129 mm).
"""
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.patches import FancyArrowPatch, Polygon

L_R, L_P = 0.085, 0.129          # m, Table I
THETA, ALPHA = np.radians(35), np.radians(22)   # drawing pose only
H = 0.035                        # height of the arm above the base (drawing only)

ARM, PEND, REF, ANG = "#1f5fa8", "#c0392b", "0.45", "#2e7d32"


def view(p, az=np.radians(20), el=np.radians(28)):
    """Axonometric projection of 3D points (..., 3) onto the page."""
    x, y, z = np.moveaxis(np.asarray(p, float), -1, 0)
    xr = x * np.cos(az) - y * np.sin(az)
    yr = x * np.sin(az) + y * np.cos(az)
    return np.stack([xr, z * np.cos(el) - yr * np.sin(el)], axis=-1)


def line3(ax, p, q, **kw):
    a, b = view([p, q])
    ax.plot([a[0], b[0]], [a[1], b[1]], **kw)


def arc3(ax, centre, u, v, a0, a1, r, arrow=True, **kw):
    """Arc of radius r about centre in the plane spanned by unit vectors u, v."""
    t = np.linspace(a0, a1, 40)
    pts = view(centre + r * (np.outer(np.cos(t), u) + np.outer(np.sin(t), v)))
    ax.plot(pts[:, 0], pts[:, 1], **kw)
    if arrow:
        ax.add_patch(FancyArrowPatch(pts[-3], pts[-1], arrowstyle="-|>", mutation_scale=9,
                                     color=kw.get("color", "k"), lw=0))
    return pts


def label(ax, p, text, dx=0.0, dy=0.0, **kw):
    q = view(p)
    kw.setdefault("fontsize", 10)
    ax.text(q[0] + dx, q[1] + dy, text, ha="center", va="center", **kw)


def panel_3d(ax):
    ez = np.array([0, 0, 1.0])
    r_hat = np.array([np.cos(THETA), np.sin(THETA), 0])      # along the arm
    t_hat = np.array([-np.sin(THETA), np.cos(THETA), 0])     # direction of positive arm rotation
    hub = np.array([0, 0, H])
    pivot = hub + L_R * r_hat
    p_dir = np.cos(ALPHA) * ez - np.sin(ALPHA) * t_hat       # leans against +theta
    tip = pivot + L_P * p_dir
    com = pivot + 0.5 * L_P * p_dir

    # base and motor
    s = 0.03
    base = np.array([[-s, -s, 0], [s, -s, 0], [s, s, 0], [-s, s, 0]])
    ax.add_patch(Polygon(view(base), closed=True, fc="0.88", ec="0.5", lw=0.8))
    lo = base * 0.012 / s
    hi = lo + [0, 0, H]
    # painter's algorithm: far faces first (depth is the rotated y used in view())
    az = np.radians(20)
    faces = [(lo[i], lo[j], hi[j], hi[i]) for i, j in [(0, 1), (1, 2), (2, 3), (3, 0)]]
    depth = lambda f: np.mean([p[0] * np.sin(az) + p[1] * np.cos(az) for p in f])
    for k, f in enumerate(sorted(faces, key=depth)):
        ax.add_patch(Polygon(view(f), closed=True, fc=("0.62", "0.75")[k % 2], ec="0.35", lw=0.7))
    ax.add_patch(Polygon(view(hi), closed=True, fc="0.85", ec="0.35", lw=0.7))
    line3(ax, [0, 0, -0.005], [0, 0, H + 0.11], color=REF, lw=0.8, ls="-.")
    label(ax, [0, 0, H + 0.118], "motor axis", color=REF, fontsize=8)
    label(ax, [0, 0, 0.5 * H], "motor\n$V_m$, $\\tau$", fontsize=8, dx=-0.035)

    # theta: reference direction and arc in the arm's plane
    line3(ax, hub, hub + [0.07, 0, 0], color=REF, lw=0.8, ls="--")
    label(ax, hub + [0.078, 0, 0], "$\\theta=0$", color=REF, fontsize=8, dx=0.006)
    arc3(ax, hub, np.array([1.0, 0, 0]), np.array([0, 1.0, 0]), 0.0, THETA, 0.045, color=ANG, lw=1.2)
    label(ax, hub + 0.055 * np.array([np.cos(THETA / 2), np.sin(THETA / 2), 0]), "$\\theta$", color=ANG, fontsize=12)

    # arm and pendulum
    line3(ax, hub, pivot, color=ARM, lw=4, solid_capstyle="round")
    label(ax, hub + 0.5 * L_R * r_hat, "$L_r$,  $m_r$", color=ARM, dx=-0.004, dy=-0.011)
    line3(ax, pivot, tip, color=PEND, lw=3.5, solid_capstyle="round")
    q = view(pivot); ax.plot(*q, "o", ms=5, mfc="white", mec="k", mew=1)
    q = view(com); ax.plot(*q, "o", ms=5, color="k")
    label(ax, tip, "$m_p$", color=PEND, dx=0.012, dy=0.004)

    # upright reference and alpha arc in the pendulum's plane (z, -t)
    line3(ax, pivot, pivot + 0.12 * ez, color=REF, lw=0.8, ls="--")
    arc3(ax, pivot, ez, -t_hat, 0.0, ALPHA, 0.085, color=ANG, lw=1.2)
    label(ax, pivot + 0.1 * (np.cos(ALPHA / 2) * ez - np.sin(ALPHA / 2) * t_hat), "$\\alpha$", color=ANG, fontsize=12)

    # direction of positive arm rotation at the joint
    a, b = view([pivot, pivot + 0.035 * t_hat])
    ax.add_patch(FancyArrowPatch(a, b, arrowstyle="-|>", mutation_scale=10, color="k", lw=1))
    label(ax, pivot + 0.035 * t_hat, "$+\\dot\\theta$", fontsize=9, dx=-0.012, dy=-0.008)

    ax.set_title("(a) Furuta pendulum", fontsize=10)


def panel_side(ax):
    """View from the motor looking out along the arm: +theta points left, +alpha is clockwise."""
    pivot = np.array([0.0, 0.0])
    d = np.array([np.sin(ALPHA), np.cos(ALPHA)])
    tip, com = pivot + L_P * d, pivot + 0.5 * L_P * d

    ax.add_patch(plt.Circle(pivot, 0.008, fc=ARM, ec="k", lw=0.8, zorder=3))
    ax.text(-0.004, -0.02, "arm (end on)", fontsize=8, ha="center", color=ARM)
    ax.plot([0, 0], [0, 0.15], color=REF, lw=0.8, ls="--")
    ax.plot(*np.c_[pivot, tip], color=PEND, lw=3.5, solid_capstyle="round")
    ax.plot(*com, "o", ms=5, color="k", zorder=4)
    ax.plot(*pivot, "o", ms=5, mfc="white", mec="k", mew=1, zorder=4)

    t = np.linspace(0, ALPHA, 30)
    r = 0.07
    ax.plot(r * np.sin(t), r * np.cos(t), color=ANG, lw=1.2)
    ax.add_patch(FancyArrowPatch((r * np.sin(t[-3]), r * np.cos(t[-3])), (r * np.sin(t[-1]), r * np.cos(t[-1])),
                                 arrowstyle="-|>", mutation_scale=9, color=ANG, lw=0))
    ax.text(0.016, 0.083, "$\\alpha$", color=ANG, fontsize=12)

    n = np.array([np.cos(ALPHA), -np.sin(ALPHA)]) * 0.013       # offset for the length labels
    for a, b, txt, k in [(pivot, com, "$l_p=L_p/2$", 3.3), (pivot, tip, "$L_p$", 5.2)]:
        a2, b2 = a + k * n, b + k * n
        ax.add_patch(FancyArrowPatch(a2, b2, arrowstyle="<->", mutation_scale=8, color="0.3", lw=0.8))
        mid = 0.5 * (a2 + b2) + 1.0 * n
        ax.text(*mid, txt, fontsize=9, rotation=-np.degrees(ALPHA) + 90, ha="center", va="center",
                rotation_mode="anchor")

    ax.add_patch(FancyArrowPatch(com, com + [0, -0.032], arrowstyle="-|>", mutation_scale=10, color="k", lw=1))
    ax.text(com[0] + 0.004, com[1] - 0.024, "$m_pg$", fontsize=9, ha="left", va="center")
    ax.add_patch(FancyArrowPatch((-0.03, -0.035), (-0.075, -0.035), arrowstyle="-|>", mutation_scale=10,
                                 color="k", lw=1))
    ax.text(-0.052, -0.05, "positive arm\nrotation", fontsize=8, ha="center", va="top")
    ax.text(0.0, 0.158, "upright, $\\alpha=0$", fontsize=8, ha="center", color=REF)
    ax.set_title("(b) Viewed from the motor along the arm", fontsize=10)


def main():
    fig, (a, b) = plt.subplots(1, 2, figsize=(7.2, 3.4), gridspec_kw={"width_ratios": [1.25, 1]})
    panel_3d(a)
    panel_side(b)
    for ax in (a, b):
        ax.set_aspect("equal")
        ax.axis("off")
    b.set_xlim(-0.1, 0.15)
    b.set_ylim(-0.1, 0.17)
    fig.tight_layout()
    out = Path(__file__).resolve().parent.parent / "figures" / "furuta_diagram.png"
    fig.savefig(out, dpi=300, bbox_inches="tight")
    print(f"Saved {out}")


if __name__ == "__main__":
    main()
