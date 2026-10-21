#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Antigravity CLI Quota Statusline (Cross-platform Python version)
Renders multi-model quota usage with ANSI color-coded progress bars.
"""
import json
import math
import sys

# Terminal ANSI color codes
esc = "\033"
cReset = f"{esc}[0m"
cBold = f"{esc}[1m"
cDim = f"{esc}[90m"
cCyan = f"{esc}[1;36m"
cGreen = f"{esc}[92m"
cYellow = f"{esc}[93m"
cRed = f"{esc}[91m"


def format_bar(frac: float, width: int) -> str:
    filled = int(round(frac * width))
    if frac > 0 and filled == 0:
        filled = 1
    empty = max(0, width - filled)

    color = cGreen if frac >= 0.5 else (cYellow if frac >= 0.2 else cRed)
    bar = ("█" * filled) + cDim + ("░" * empty) + cReset
    return f"{color}[{bar}{color}]{cReset}"


def format_time(sec: int) -> str:
    if not sec or sec <= 0:
        return "0m"
    h = math.floor(sec / 3600)
    m = math.floor((sec % 3600) / 60)
    if h >= 24:
        d = round(h / 24, 1)
        return f"{int(d)}d" if d == int(d) else f"{d}d"
    if h > 0:
        return f"{h}h"
    return f"{m}m"


def main():
    try:
        raw_input = sys.stdin.read()
        if not raw_input or not raw_input.strip():
            sys.exit(0)

        data = json.loads(raw_input)
    except Exception:
        sys.exit(0)

    try:
        # Terminal width and dynamic sizing
        term_width = data.get("terminal_width")
        term_width = int(term_width) if (term_width and int(term_width) > 0) else 120
        bar_width = 5 if term_width >= 120 else 4
        show_reset_time = term_width >= 130

        # Group quotas by model family
        models = {
            "Gemini": {},
            "Argon": {},
            "Claude": {},
        }

        quota_data = data.get("quota") or {}
        items = []
        if isinstance(quota_data, dict):
            items = list(quota_data.items())
        elif isinstance(quota_data, list):
            items = [(b.get("bucket_id") or b.get("model_id") or "quota", b) for b in quota_data if isinstance(b, dict)]

        for k, val in items:
            if not isinstance(val, dict):
                continue
            k_lower = str(k).lower()
            if k_lower.startswith("gemini-argon"):
                win = "5h" if "5h" in k_lower else ("Wk" if "weekly" in k_lower else k)
                models["Argon"][win] = val
            elif k_lower.startswith("gemini"):
                win = "5h" if "5h" in k_lower else ("Wk" if "weekly" in k_lower else k)
                models["Gemini"][win] = val
            elif k_lower.startswith("3p") or k_lower.startswith("claude"):
                win = "5h" if "5h" in k_lower else ("Wk" if "weekly" in k_lower else k)
                models["Claude"][win] = val
            else:
                prefix = k.split("-")[0].capitalize()
                if prefix not in models:
                    models[prefix] = {}
                win = "5h" if "5h" in k_lower else ("Wk" if "weekly" in k_lower else k)
                models[prefix][win] = val

        # Active model detection
        model_info = data.get("model") or {}
        active_model = ""
        if isinstance(model_info, dict):
            active_model = model_info.get("display_name") or model_info.get("id") or ""
        elif isinstance(model_info, str):
            active_model = model_info
        active_model_lower = active_model.lower()

        model_outputs = []
        for m_name, buckets in models.items():
            if not buckets:
                continue

            is_active = False
            if m_name == "Argon" and "argon" in active_model_lower:
                is_active = True
            elif m_name == "Gemini" and "gemini" in active_model_lower and "argon" not in active_model_lower:
                is_active = True
            elif m_name == "Claude" and ("claude" in active_model_lower or "3p" in active_model_lower):
                is_active = True

            badge = f"{cCyan}*[{m_name}]*{cReset}" if is_active else f"{cBold}[{m_name}]{cReset}"

            # Sort window keys so 5h is always first, followed by Wk or other
            sorted_keys = sorted(buckets.keys(), key=lambda w: (0 if w == "5h" else 1, w))
            part_list = []
            for w in sorted_keys:
                info = buckets[w]
                frac_val = info.get("remaining_fraction")
                frac = max(0.0, min(1.0, float(frac_val))) if frac_val is not None else 0.0
                pct = int(round(frac * 100))
                bar = format_bar(frac, bar_width)

                pct_color = cGreen if frac >= 0.5 else (cYellow if frac >= 0.2 else cRed)
                pct_str = f"{pct_color}{pct}%{cReset}"

                if show_reset_time:
                    reset_str = format_time(int(info.get("reset_in_seconds", 0)))
                    part_list.append(f"{w}:{bar} {pct_str} {cDim}({reset_str}){cReset}")
                else:
                    part_list.append(f"{w}:{bar} {pct_str}")

            model_outputs.append(f"{badge} " + "  ".join(part_list))

        if not model_outputs:
            print("Quota: N/A")
        else:
            divider = f"  {cDim}|{cReset}  "
            print(divider.join(model_outputs))

    except Exception:
        sys.exit(0)


if __name__ == "__main__":
    main()
