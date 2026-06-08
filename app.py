# =========================================================
# Smart Laptop & Phone Repair Diagnosis Expert System
# File: app.py
# Frontend: Tkinter UI
# Backend: SWI-Prolog file repair_expert.pl
# =========================================================

import os
import subprocess
import tkinter as tk
from tkinter import ttk, messagebox

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PROLOG_FILE = os.path.join(BASE_DIR, "repair_expert.pl")

SYMPTOMS = {
    "laptop": [
        ("no_power", "Does not power on"),
        ("no_charging", "Does not charge"),
        ("battery_drain", "Battery drains quickly"),
        ("random_shutdown", "Random shutdown"),
        ("overheating", "Overheating"),
        ("loud_fan", "Fan is very loud"),
        ("black_screen", "Black screen"),
        ("display_flicker", "Display flickering"),
        ("slow_performance", "Slow performance"),
        ("boot_failure", "Boot failure"),
        ("clicking_sound", "Clicking sound from storage"),
        ("keyboard_not_working", "Keyboard not working"),
        ("wifi_not_working", "Wi-Fi not working"),
        ("virus_popups", "Unwanted popups / suspicious apps"),
        ("blue_screen", "Blue screen / system crash"),
    ],
    "phone": [
        ("no_power", "Does not power on"),
        ("no_charging", "Does not charge"),
        ("battery_drain", "Battery drains quickly"),
        ("random_shutdown", "Random shutdown"),
        ("overheating", "Overheating"),
        ("cracked_screen", "Cracked screen"),
        ("black_screen", "Black screen"),
        ("touch_not_working", "Touch not working"),
        ("slow_performance", "Slow performance"),
        ("storage_full", "Storage full"),
        ("wifi_not_working", "Wi-Fi not working"),
        ("camera_not_working", "Camera not working"),
        ("speaker_not_working", "Speaker not working"),
        ("water_damage", "Water damage"),
        ("boot_loop", "Phone stuck in boot loop"),
    ],
}

def prolog_list(items):
    """Build a Prolog list of atoms from Python strings."""
    return "[" + ",".join(items) + "]"


def run_prolog_diagnosis(device, symptoms):
    """Call SWI-Prolog and return parsed diagnosis rows."""
    if not os.path.exists(PROLOG_FILE):
        raise FileNotFoundError("repair_expert.pl was not found in the project folder.")

    goal = f"run_diagnosis({device}, {prolog_list(symptoms)})"
    command = ["swipl", "-q", "-s", PROLOG_FILE, "-g", goal]

    completed = subprocess.run(
        command,
        capture_output=True,
        text=True,
        cwd=BASE_DIR,
        timeout=15,
        check=False,
    )

    if completed.returncode != 0:
        raise RuntimeError(completed.stderr.strip() or "SWI-Prolog failed to run.")

    rows = []
    for line in completed.stdout.splitlines():
        parts = line.split("|")
        if not parts:
            continue
        if parts[0] == "NO_RESULT":
            rows.append({
                "fault": "No strong match",
                "score": "0",
                "match_count": "0",
                "match_total": "0",
                "severity": "-",
                "cost": "-",
                "label": parts[1] if len(parts) > 1 else "No strong fault matched",
                "advice": parts[2] if len(parts) > 2 else "Select more symptoms.",
                "matched": "",
            })
        elif parts[0] == "RESULT" and len(parts) >= 10:
            rows.append({
                "fault": parts[1],
                "score": parts[2],
                "match_count": parts[3],
                "match_total": parts[4],
                "severity": parts[5],
                "cost": parts[6],
                "label": parts[7],
                "advice": parts[8],
                "matched": parts[9],
            })
    return rows


class RepairDiagnosisApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Smart Device Repair Diagnosis Expert System")
        self.geometry("1100x720")
        self.minsize(950, 620)
        self.configure(bg="#f4f7fb")

        self.device_var = tk.StringVar(value="laptop")
        self.symptom_vars = {}
        self._build_style()
        self._build_layout()
        self.render_symptoms()

    def _build_style(self):
        style = ttk.Style(self)
        style.theme_use("clam")
        style.configure("TFrame", background="#f4f7fb")
        style.configure("Card.TFrame", background="white", relief="flat")
        style.configure("Title.TLabel", font=("Segoe UI", 22, "bold"), background="#f4f7fb", foreground="#172033")
        style.configure("Sub.TLabel", font=("Segoe UI", 11), background="#f4f7fb", foreground="#596579")
        style.configure("CardTitle.TLabel", font=("Segoe UI", 14, "bold"), background="white", foreground="#172033")
        style.configure("TButton", font=("Segoe UI", 10, "bold"), padding=8)
        style.configure("Accent.TButton", background="#2563eb", foreground="white")
        style.configure("TCheckbutton", background="white", font=("Segoe UI", 10))
        style.configure("Treeview", font=("Segoe UI", 10), rowheight=30)
        style.configure("Treeview.Heading", font=("Segoe UI", 10, "bold"))

    def _build_layout(self):
        header = ttk.Frame(self)
        header.pack(fill="x", padx=24, pady=(20, 10))
        ttk.Label(header, text="Smart Laptop & Phone Repair Diagnosis", style="Title.TLabel").pack(anchor="w")
        ttk.Label(
            header,
            text="Rule-based Prolog expert system with a Tkinter graphical interface",
            style="Sub.TLabel",
        ).pack(anchor="w", pady=(4, 0))

        body = ttk.Frame(self)
        body.pack(fill="both", expand=True, padx=24, pady=12)

        left = ttk.Frame(body, style="Card.TFrame")
        left.pack(side="left", fill="both", expand=False, padx=(0, 12), ipadx=18, ipady=16)

        right = ttk.Frame(body, style="Card.TFrame")
        right.pack(side="right", fill="both", expand=True, padx=(12, 0), ipadx=18, ipady=16)

        ttk.Label(left, text="1. Select Device", style="CardTitle.TLabel").pack(anchor="w", padx=16, pady=(16, 8))
        device_row = ttk.Frame(left, style="Card.TFrame")
        device_row.pack(anchor="w", padx=16, pady=(0, 16))
        ttk.Radiobutton(device_row, text="Laptop", variable=self.device_var, value="laptop", command=self.render_symptoms).pack(side="left", padx=(0, 12))
        ttk.Radiobutton(device_row, text="Phone", variable=self.device_var, value="phone", command=self.render_symptoms).pack(side="left")

        ttk.Label(left, text="2. Select Symptoms", style="CardTitle.TLabel").pack(anchor="w", padx=16, pady=(0, 8))

        self.symptom_canvas = tk.Canvas(left, width=390, height=390, bg="white", highlightthickness=0)
        self.symptom_frame = ttk.Frame(self.symptom_canvas, style="Card.TFrame")
        self.symptom_scroll = ttk.Scrollbar(left, orient="vertical", command=self.symptom_canvas.yview)
        self.symptom_canvas.configure(yscrollcommand=self.symptom_scroll.set)
        self.symptom_canvas.pack(side="left", fill="both", expand=True, padx=(16, 0), pady=(0, 12))
        self.symptom_scroll.pack(side="right", fill="y", padx=(0, 16), pady=(0, 12))
        self.symptom_canvas.create_window((0, 0), window=self.symptom_frame, anchor="nw")
        self.symptom_frame.bind("<Configure>", lambda e: self.symptom_canvas.configure(scrollregion=self.symptom_canvas.bbox("all")))

        button_row = ttk.Frame(left, style="Card.TFrame")
        button_row.pack(fill="x", padx=16, pady=(0, 16))
        ttk.Button(button_row, text="Diagnose Now", style="Accent.TButton", command=self.diagnose).pack(side="left", fill="x", expand=True)
        ttk.Button(button_row, text="Clear", command=self.clear_selection).pack(side="left", padx=(10, 0))

        ttk.Label(right, text="Diagnosis Results", style="CardTitle.TLabel").pack(anchor="w", padx=16, pady=(16, 8))
        columns = ("match", "fault", "severity", "cost")
        self.tree = ttk.Treeview(right, columns=columns, show="headings", height=8)
        for col, heading, width in [("match", "Match", 70), ("fault", "Fault", 260), ("severity", "Severity", 90), ("cost", "Cost", 80)]:
            self.tree.heading(col, text=heading)
            self.tree.column(col, width=width, anchor="w")
        self.tree.pack(fill="x", padx=16, pady=(0, 12))
        self.tree.bind("<<TreeviewSelect>>", self.show_selected_detail)

        # --- Detail area: summary and advice boxes ---
        detail_area = ttk.Frame(right, style="Card.TFrame")
        detail_area.pack(fill="both", expand=True, padx=16, pady=(8, 8))

        # Box 1: Fault Summary
        self.box_summary = tk.Frame(detail_area, bg="#eef2ff", relief="groove", bd=1, padx=14, pady=10)
        self.box_summary.pack(fill="x", pady=(0, 6))
        self.lbl_fault_name = tk.Label(self.box_summary, text="—", font=("Segoe UI", 13, "bold"), bg="#eef2ff", fg="#172033", anchor="w")
        self.lbl_fault_name.pack(fill="x")
        self.summary_grid = tk.Frame(self.box_summary, bg="#eef2ff")
        self.summary_grid.pack(fill="x", pady=(6, 0))
        self._summary_labels = {}
        for col, key in enumerate(["Match", "Severity", "Cost"]):
            tk.Label(self.summary_grid, text=key, font=("Segoe UI", 9, "bold"), bg="#eef2ff", fg="#596579").grid(row=0, column=col, sticky="w", padx=(0, 24))
            lbl = tk.Label(self.summary_grid, text="—", font=("Segoe UI", 10), bg="#eef2ff", fg="#172033")
            lbl.grid(row=1, column=col, sticky="w", padx=(0, 24))
            self._summary_labels[key] = lbl

        # Box 2: Matched Symptoms + Repair Advice
        self.box_advice = tk.Frame(detail_area, bg="#fffbeb", relief="groove", bd=1, padx=14, pady=10)
        self.box_advice.pack(fill="both", expand=True, pady=(0, 0))
        tk.Label(self.box_advice, text="Matched Symptoms", font=("Segoe UI", 9, "bold"), bg="#fffbeb", fg="#596579", anchor="w").pack(fill="x")
        self.lbl_symptoms = tk.Label(self.box_advice, text="—", font=("Segoe UI", 10), bg="#fffbeb", fg="#475569", anchor="w", wraplength=500, justify="left")
        self.lbl_symptoms.pack(fill="x", pady=(2, 8))
        tk.Label(self.box_advice, text="Repair Advice", font=("Segoe UI", 9, "bold"), bg="#fffbeb", fg="#596579", anchor="w").pack(fill="x")
        self.lbl_advice = tk.Label(self.box_advice, text="—", font=("Segoe UI", 10), bg="#fffbeb", fg="#1e3a5f", anchor="nw", wraplength=500, justify="left")
        self.lbl_advice.pack(fill="both", expand=True, pady=(2, 0))

    def render_symptoms(self):
        for child in self.symptom_frame.winfo_children():
            child.destroy()
        self.symptom_vars.clear()
        device = self.device_var.get()
        for atom, label in SYMPTOMS[device]:
            var = tk.BooleanVar(value=False)
            self.symptom_vars[atom] = var
            ttk.Checkbutton(self.symptom_frame, text=label, variable=var).pack(anchor="w", pady=4, padx=4)

    def selected_symptoms(self):
        return [atom for atom, var in self.symptom_vars.items() if var.get()]

    def clear_selection(self):
        for var in self.symptom_vars.values():
            var.set(False)
        for row in self.tree.get_children():
            self.tree.delete(row)
        self._clear_detail_boxes()

    def _clear_detail_boxes(self):
        self.lbl_fault_name.config(text="—")
        for lbl in self._summary_labels.values():
            lbl.config(text="—", fg="#172033")
        self.lbl_symptoms.config(text="—")
        self.lbl_advice.config(text="—")

    def diagnose(self):
        symptoms = self.selected_symptoms()
        if not symptoms:
            messagebox.showwarning("No symptoms", "Please select at least one symptom.")
            return
        try:
            rows = run_prolog_diagnosis(self.device_var.get(), symptoms)
        except Exception as exc:
            messagebox.showerror("Prolog Error", str(exc))
            return

        for row in self.tree.get_children():
            self.tree.delete(row)
        self.results = rows
        for idx, row in enumerate(rows):
            self.tree.insert("", "end", iid=str(idx), values=(
                f"{row['match_count']}/{row['match_total']}",
                row["label"],
                row["severity"],
                row["cost"],
            ))
        if rows:
            self.tree.selection_set("0")
            self.show_selected_detail()

    def _severity_color(self, severity):
        return {"low": "#16a34a", "medium": "#d97706", "high": "#ea580c", "critical": "#dc2626"}.get(severity, "#172033")

    def show_selected_detail(self, event=None):
        selected = self.tree.selection()
        if not selected:
            return
        row = self.results[int(selected[0])]

        # Box 1: Summary
        self.lbl_fault_name.config(text=row["label"])
        self._summary_labels["Match"].config(text=f"{row['match_count']}/{row['match_total']}")
        self._summary_labels["Severity"].config(text=row["severity"].upper(), fg=self._severity_color(row["severity"]))
        self._summary_labels["Cost"].config(text=row["cost"])

        # Box 2: Symptoms + Advice
        matched = row["matched"].replace(",", ",  ") if row["matched"] else "—"
        self.lbl_symptoms.config(text=matched)
        self.lbl_advice.config(text=row["advice"])

if __name__ == "__main__":
    app = RepairDiagnosisApp()
    app.mainloop()
