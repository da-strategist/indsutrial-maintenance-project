"""
Generate mtbf_dashboard_mockup.excalidraw
Run: python dashboards/generate_mtbf_dashboard.py
"""
import json, math, random

random.seed(42)
elements = []
eid = 0

def nid():
    global eid
    eid += 1
    return f"el_{eid:04d}"

def rect(x, y, w, h, bg="#ffffff", stroke="#e2e8f0", sw=1, roughness=0,
         fill="solid", rounded=False, opacity=100, stroke_style="solid"):
    return {
        "id": nid(), "type": "rectangle",
        "x": x, "y": y, "width": w, "height": h, "angle": 0,
        "strokeColor": stroke, "backgroundColor": bg,
        "fillStyle": fill, "strokeWidth": sw, "strokeStyle": stroke_style,
        "roughness": roughness, "opacity": opacity,
        "groupIds": [], "roundness": {"type": 3} if rounded else None,
    }

def text(x, y, w, h, content, size=14, color="#0f172a", align="left",
         family=2, bold=False, valign="top"):
    return {
        "id": nid(), "type": "text",
        "x": x, "y": y, "width": w, "height": h, "angle": 0,
        "strokeColor": color, "backgroundColor": "transparent",
        "fillStyle": "solid", "strokeWidth": 1, "strokeStyle": "solid",
        "roughness": 0, "opacity": 100, "groupIds": [], "roundness": None,
        "text": content, "fontSize": size, "fontFamily": family,
        "textAlign": align, "verticalAlign": valign,
        "containerId": None, "originalText": content,
    }

def line(x1, y1, x2, y2, color="#94a3b8", sw=1.5, style="solid"):
    lx = min(x1, x2); ly = min(y1, y2)
    return {
        "id": nid(), "type": "line",
        "x": lx, "y": ly,
        "width": abs(x2-x1), "height": abs(y2-y1), "angle": 0,
        "strokeColor": color, "backgroundColor": "transparent",
        "fillStyle": "solid", "strokeWidth": sw, "strokeStyle": style,
        "roughness": 0, "opacity": 100, "groupIds": [], "roundness": None,
        "points": [[x1-lx, y1-ly], [x2-lx, y2-ly]],
        "startArrowhead": None, "endArrowhead": None,
    }

def ellipse(x, y, w, h, bg="#3b82f6", stroke="#3b82f6", opacity=100):
    return {
        "id": nid(), "type": "ellipse",
        "x": x, "y": y, "width": w, "height": h, "angle": 0,
        "strokeColor": stroke, "backgroundColor": bg,
        "fillStyle": "solid", "strokeWidth": 1, "strokeStyle": "solid",
        "roughness": 0, "opacity": opacity, "groupIds": [], "roundness": None,
    }

# ─── CANVAS BACKGROUND ───────────────────────────────────────────────────────
elements.append(rect(0, 0, 2040, 1010, bg="#f1f5f9", stroke="transparent", sw=0))

# ─── HEADER ──────────────────────────────────────────────────────────────────
elements.append(rect(0, 0, 2040, 68, bg="#1e3a5f", stroke="transparent", sw=0))
elements.append(text(24, 14, 700, 34, "Asset Failure & MTBF Analysis Dashboard",
                     size=22, color="#ffffff", family=2))
elements.append(text(24, 46, 600, 18, "Source: int_asset_failures_mtbf  |  Industrial Maintenance Platform",
                     size=12, color="#93c5fd"))
# Badge
elements.append(rect(1870, 16, 148, 36, bg="#2563eb", stroke="transparent", rounded=True))
elements.append(text(1878, 24, 132, 20, "MTBF Dashboard", size=13, color="#ffffff", align="center"))

# ─── FILTER BAR ──────────────────────────────────────────────────────────────
elements.append(rect(0, 68, 2040, 46, bg="#e2e8f0", stroke="#cbd5e1", sw=1))
elements.append(text(24, 80, 70, 20, "Asset:", size=13, color="#475569"))
elements.append(rect(88, 76, 160, 28, bg="#ffffff", stroke="#94a3b8", rounded=True))
elements.append(text(96, 81, 144, 18, "All Assets ▾", size=12, color="#374151"))

elements.append(text(270, 80, 90, 20, "Date Range:", size=13, color="#475569"))
elements.append(rect(358, 76, 200, 28, bg="#ffffff", stroke="#94a3b8", rounded=True))
elements.append(text(366, 81, 184, 18, "Jan 2024 – Jun 2024 ▾", size=12, color="#374151"))

elements.append(text(578, 80, 70, 20, "Region:", size=13, color="#475569"))
elements.append(rect(644, 76, 160, 28, bg="#ffffff", stroke="#94a3b8", rounded=True))
elements.append(text(652, 81, 144, 18, "All Regions ▾", size=12, color="#374151"))

elements.append(rect(826, 76, 90, 28, bg="#2563eb", stroke="transparent", rounded=True))
elements.append(text(834, 81, 74, 18, "Apply Filter", size=12, color="#ffffff", align="center"))

# ─── KPI CARDS ───────────────────────────────────────────────────────────────
KPI_Y = 126
KPI_H = 118
cards = [
    # (x, w, accent_color, label, value, delta, delta_color, icon)
    (20,  478, "#3b82f6", "Avg Fleet MTBF",          "52.4 days",  "▲ +5.2d vs prev period", "#16a34a", "⏱"),
    (518, 478, "#ef4444", "Total Failure Events",     "1,284",      "▼ -3.1% vs prev period", "#16a34a", "⚠"),
    (1016,478, "#f59e0b", "Assets Below Threshold",   "3 Assets",   "▼ -1 vs prev period",    "#16a34a", "📊"),
    (1514,506, "#10b981", "Best Performer MTBF",      "AST-005: 89d","↔ Stable",              "#64748b", "🏆"),
]
for (cx, cw, accent, label, value, delta, dcol, icon) in cards:
    elements.append(rect(cx, KPI_Y, cw, KPI_H, bg="#ffffff", stroke="#e2e8f0", rounded=True))
    elements.append(rect(cx, KPI_Y, cw, 5, bg=accent, stroke="transparent", rounded=False))
    elements.append(text(cx+16, KPI_Y+16, cw-80, 18, label, size=13, color="#64748b"))
    elements.append(text(cx+16, KPI_Y+38, cw-32, 38, value, size=32, color="#0f172a", family=2))
    elements.append(text(cx+16, KPI_Y+84, cw-32, 18, delta, size=12, color=dcol))
    elements.append(text(cx+cw-52, KPI_Y+20, 40, 40, icon, size=28, color=accent, align="center"))

# ─── CHART CONTAINERS ────────────────────────────────────────────────────────
CR1_Y = 256  # chart row 1 top
CR2_Y = 564  # chart row 2 top
CR1_H = 296
CR2_H = 374

elements.append(rect(20,  CR1_Y, 960, CR1_H, bg="#ffffff", stroke="#e2e8f0", rounded=True))
elements.append(rect(1000,CR1_Y,1020, CR1_H, bg="#ffffff", stroke="#e2e8f0", rounded=True))
elements.append(rect(20,  CR2_Y, 960, CR2_H, bg="#ffffff", stroke="#e2e8f0", rounded=True))
elements.append(rect(1000,CR2_Y,1020, CR2_H, bg="#ffffff", stroke="#e2e8f0", rounded=True))

# ─── CHART 1: BAR CHART — MTBF by Asset ─────────────────────────────────────
elements.append(text(38, CR1_Y+12, 500, 22,
                     "MTBF by Asset (days)", size=15, color="#0f172a", family=2))
elements.append(text(38, CR1_Y+34, 600, 16,
                     "Mean time between failures per asset | Jan–Jun 2024", size=11, color="#64748b"))

XAXIS_Y = CR1_Y + CR1_H - 42   # y=510
CHART1_TOP = CR1_Y + 58         # y=314
CHART1_HEIGHT = XAXIS_Y - CHART1_TOP  # 196px
YAXIS_X = 100

# Y-axis
elements.append(line(YAXIS_X, CHART1_TOP, YAXIS_X, XAXIS_Y, color="#cbd5e1", sw=1))
# X-axis
elements.append(line(YAXIS_X, XAXIS_Y, 960, XAXIS_Y, color="#cbd5e1", sw=1))

assets = ["AST-001","AST-002","AST-003","AST-004","AST-005","AST-006","AST-007","AST-008"]
mtbf_vals = [78, 45, 62, 31, 89, 55, 42, 71]
THRESHOLD = 45
MAX_MTBF = 89
bar_w = 72
bar_gap = 24
bar_start_x = YAXIS_X + 16

for i, (asset, mv) in enumerate(zip(assets, mtbf_vals)):
    bx = bar_start_x + i * (bar_w + bar_gap)
    bh = int(mv / MAX_MTBF * CHART1_HEIGHT)
    by = XAXIS_Y - bh
    color = "#ef4444" if mv < THRESHOLD else "#3b82f6"
    border = "#dc2626" if mv < THRESHOLD else "#2563eb"
    elements.append(rect(bx, by, bar_w, bh, bg=color, stroke=border, sw=1, rounded=False))
    # Value label above bar
    elements.append(text(bx, by-18, bar_w, 16, f"{mv}d", size=11,
                         color=color, align="center"))
    # X-axis label
    lbl = asset.replace("AST-","")
    elements.append(text(bx, XAXIS_Y+6, bar_w, 14, asset, size=10,
                         color="#475569", align="center"))

# Y-axis ticks & gridlines
for tick in [0, 20, 40, 60, 80]:
    ty = XAXIS_Y - int(tick / MAX_MTBF * CHART1_HEIGHT)
    elements.append(line(YAXIS_X-5, ty, YAXIS_X, ty, color="#94a3b8", sw=1))
    elements.append(line(YAXIS_X, ty, 960, ty, color="#f1f5f9", sw=1, style="dashed"))
    elements.append(text(44, ty-8, 52, 16, f"{tick}d", size=10, color="#64748b", align="right"))

# Threshold line
thresh_y = XAXIS_Y - int(THRESHOLD / MAX_MTBF * CHART1_HEIGHT)
elements.append(line(YAXIS_X, thresh_y, 955, thresh_y, color="#ef4444", sw=1.5, style="dashed"))
elements.append(text(856, thresh_y-16, 100, 14, f"Threshold ({THRESHOLD}d)", size=10, color="#ef4444"))

# Legend
elements.append(rect(108, CR1_Y+14, 12, 12, bg="#3b82f6", stroke="transparent"))
elements.append(text(124, CR1_Y+13, 80, 14, "Normal", size=10, color="#475569"))
elements.append(rect(192, CR1_Y+14, 12, 12, bg="#ef4444", stroke="transparent"))
elements.append(text(208, CR1_Y+13, 100, 14, "Below Threshold", size=10, color="#475569"))

# ─── CHART 2: LINE CHART — MTBF Trend ────────────────────────────────────────
elements.append(text(1018, CR1_Y+12, 500, 22,
                     "Fleet MTBF Trend (Monthly Avg)", size=15, color="#0f172a", family=2))
elements.append(text(1018, CR1_Y+34, 600, 16,
                     "Average MTBF across all assets per month", size=11, color="#64748b"))

XAXIS2_Y = XAXIS_Y
CHART2_TOP = CHART1_TOP
CHART2_HEIGHT = CHART1_HEIGHT
YAXIS2_X = 1080
RIGHT2 = 1995

months = ["Jan","Feb","Mar","Apr","May","Jun"]
month_mtbf = [38, 42, 35, 51, 48, 55]
MAX2 = 60
x_spacing = (RIGHT2 - YAXIS2_X) / (len(months) - 1)

px = [int(YAXIS2_X + i * x_spacing) for i in range(6)]
py = [int(XAXIS2_Y - mv / MAX2 * CHART2_HEIGHT) for mv in month_mtbf]

# Y-axis & X-axis
elements.append(line(YAXIS2_X, CHART2_TOP, YAXIS2_X, XAXIS2_Y, color="#cbd5e1", sw=1))
elements.append(line(YAXIS2_X, XAXIS2_Y, RIGHT2+10, XAXIS2_Y, color="#cbd5e1", sw=1))

# Gridlines
for tick in [0, 15, 30, 45, 60]:
    gy = XAXIS2_Y - int(tick / MAX2 * CHART2_HEIGHT)
    elements.append(line(YAXIS2_X, gy, RIGHT2, gy, color="#f1f5f9", sw=1, style="dashed"))
    elements.append(text(1020, gy-8, 56, 16, f"{tick}d", size=10, color="#64748b", align="right"))

# Area fill (semi-transparent)
# Simulate with a faint rectangle under the line trend
elements.append(rect(px[0], py[5]-5, RIGHT2-px[0], XAXIS2_Y-py[5]+5,
                     bg="#eff6ff", stroke="transparent", opacity=40))

# Line segments
for i in range(len(px)-1):
    elements.append(line(px[i], py[i], px[i+1], py[i+1], color="#3b82f6", sw=2.5))

# Dots + value labels
for i, (x, y, mv) in enumerate(zip(px, py, month_mtbf)):
    elements.append(ellipse(x-7, y-7, 14, 14, bg="#ffffff", stroke="#3b82f6"))
    elements.append(ellipse(x-4, y-4, 8, 8, bg="#3b82f6", stroke="#3b82f6"))
    elements.append(text(x-20, y-22, 40, 16, f"{mv}d", size=11, color="#1d4ed8", align="center"))
    elements.append(text(x-20, XAXIS2_Y+6, 40, 14, months[i], size=11, color="#475569", align="center"))

# ─── CHART 3: HEATMAP — Failure Frequency by Asset & Month ───────────────────
elements.append(text(38, CR2_Y+12, 500, 22,
                     "Failure Frequency Heatmap", size=15, color="#0f172a", family=2))
elements.append(text(38, CR2_Y+34, 700, 16,
                     "Number of failure events per asset per month | Jan–Jun 2024", size=11, color="#64748b"))

HEAT_X = 145   # grid left
HEAT_Y = CR2_Y + 72  # grid top (after headers)
CELL_W = 130
CELL_H = 33

# Month headers
for j, mo in enumerate(months):
    cx = HEAT_X + j * CELL_W + CELL_W//2 - 15
    elements.append(text(cx, CR2_Y+54, 60, 16, mo, size=12, color="#475569", align="center"))

# Heatmap data [row=asset, col=month]
heatmap_data = [
    [0, 1, 0, 2, 1, 0],   # AST-001
    [2, 1, 3, 1, 2, 1],   # AST-002
    [0, 0, 1, 0, 0, 1],   # AST-003
    [3, 2, 4, 3, 2, 3],   # AST-004
    [0, 1, 0, 0, 1, 0],   # AST-005
    [1, 2, 1, 3, 2, 1],   # AST-006
    [2, 3, 2, 1, 3, 2],   # AST-007
    [4, 3, 5, 4, 3, 4],   # AST-008
]
heat_colors = {0:"#dcfce7",1:"#fef9c3",2:"#fed7aa",3:"#fca5a5",4:"#f87171",5:"#dc2626"}
heat_text   = {0:"#166534",1:"#854d0e",2:"#9a3412",3:"#991b1b",4:"#7f1d1d",5:"#ffffff"}

for i, (asset, row) in enumerate(zip(assets, heatmap_data)):
    ry = HEAT_Y + i * CELL_H
    # Asset label
    elements.append(text(22, ry+8, 120, 18, asset, size=11, color="#374151"))
    for j, val in enumerate(row):
        cx = HEAT_X + j * CELL_W
        elements.append(rect(cx, ry, CELL_W-2, CELL_H-2,
                             bg=heat_colors[val], stroke="#e2e8f0", sw=1))
        elements.append(text(cx + CELL_W//2 - 8, ry+8, 24, 18,
                             str(val), size=12, color=heat_text[val], align="center"))

# Legend
LEG_Y = CR2_Y + CR2_H - 30
elements.append(text(22, LEG_Y, 60, 16, "Failures:", size=11, color="#475569"))
for i, (val, col) in enumerate(heat_colors.items()):
    lx = 90 + i * 90
    elements.append(rect(lx, LEG_Y, 20, 14, bg=col, stroke="#e2e8f0"))
    elements.append(text(lx+24, LEG_Y, 60, 14, f"{val}" if val < 5 else "5+",
                         size=10, color="#475569"))

# ─── CHART 4: TABLE — Asset Failure Detail ───────────────────────────────────
elements.append(text(1018, CR2_Y+12, 500, 22,
                     "Asset Failure Detail", size=15, color="#0f172a", family=2))
elements.append(text(1018, CR2_Y+34, 700, 16,
                     "Per-asset failure counts, MTBF, and status", size=11, color="#64748b"))

TBL_X = 1010
TBL_HDR_Y = CR2_Y + 58
COL_WS  = [170, 120, 155, 175, 130]
COL_HDR = ["Asset ID", "Fail Count", "Avg MTBF (d)", "Last Failure", "Status"]
COL_XS  = [TBL_X + sum(COL_WS[:i]) for i in range(5)]

# Header row background
elements.append(rect(TBL_X, TBL_HDR_Y, sum(COL_WS), 30, bg="#1e3a5f", stroke="transparent"))
for cx, hw, hdr in zip(COL_XS, COL_WS, COL_HDR):
    elements.append(text(cx+8, TBL_HDR_Y+7, hw-16, 18, hdr, size=11,
                         color="#e2e8f0", family=2))

# Table data
table_data = [
    ("AST-001",  4, 78.5, "2024-06-12", "Normal",  "#16a34a"),
    ("AST-002", 10, 45.2, "2024-06-28", "Warning", "#d97706"),
    ("AST-003",  2, 89.0, "2024-05-15", "Normal",  "#16a34a"),
    ("AST-004", 17, 31.4, "2024-06-30", "At Risk", "#dc2626"),
    ("AST-005",  3, 72.3, "2024-05-22", "Normal",  "#16a34a"),
    ("AST-006",  8, 55.1, "2024-06-18", "Warning", "#d97706"),
    ("AST-007", 11, 42.0, "2024-06-25", "Warning", "#d97706"),
    ("AST-008", 20, 28.7, "2024-07-01", "At Risk", "#dc2626"),
]
for ri, (aid, fc, avg, lf, status, sc) in enumerate(table_data):
    ry = TBL_HDR_Y + 30 + ri * 30
    row_bg = "#f8fafc" if ri % 2 == 0 else "#ffffff"
    elements.append(rect(TBL_X, ry, sum(COL_WS), 30, bg=row_bg, stroke="#f1f5f9", sw=1))
    row_vals = [aid, str(fc), f"{avg:.1f}", lf, status]
    row_cols = ["#0f172a","#0f172a","#0f172a","#0f172a", sc]
    for cx, cw, val, col in zip(COL_XS, COL_WS, row_vals, row_cols):
        # Status badge
        if val == status and status != "Normal":
            elements.append(rect(cx+6, ry+7, cw-12, 17,
                                 bg=sc+"22" if len(sc)==7 else "#fff",
                                 stroke=sc, rounded=True))
        elements.append(text(cx+8, ry+7, cw-16, 18, val, size=11, color=col))

# Divider lines between columns in table header
for cx in COL_XS[1:]:
    elements.append(line(cx, TBL_HDR_Y, cx, TBL_HDR_Y+30+len(table_data)*30,
                         color="#e2e8f0", sw=1))

# ─── FOOTER ──────────────────────────────────────────────────────────────────
elements.append(rect(0, 950, 2040, 40, bg="#1e3a5f", stroke="transparent", sw=0))
elements.append(text(24, 960, 800, 18,
                     "Industrial Maintenance Analytics Platform  |  Data: BigQuery inds_proj.int_layer",
                     size=11, color="#93c5fd"))
elements.append(text(1700, 960, 320, 18,
                     "Last refreshed: Jun 2024  |  Power BI Mockup",
                     size=11, color="#93c5fd", align="right"))

# ─── OUTPUT ──────────────────────────────────────────────────────────────────
out = {
    "type": "excalidraw",
    "version": 2,
    "source": "https://excalidraw.com",
    "elements": elements,
    "appState": {
        "gridSize": None,
        "viewBackgroundColor": "#f1f5f9",
    },
    "files": {}
}

import os
out_path = os.path.join(os.path.dirname(__file__), "mtbf_dashboard_mockup.excalidraw")
with open(out_path, "w") as f:
    json.dump(out, f, indent=2)

print(f"✓ Written {len(elements)} elements → {out_path}")
