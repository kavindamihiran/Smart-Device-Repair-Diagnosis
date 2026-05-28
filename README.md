# Smart Laptop & Phone Repair Diagnosis Expert System

**Course:** CM2520 - Deductive Reasoning and Logic Programming  
**Backend:** SWI-Prolog  
**Frontend:** Python Tkinter GUI

## Overview

A rule-based expert system that diagnoses common laptop and phone repair issues from user-selected symptoms. The Prolog backend reasons over the symptoms and returns possible faults, confidence scores, severity levels, estimated cost, backup warnings, and repair advice.

## Features

- **Device Selection:** Laptop and Phone support
- **Symptom-based Diagnosis:** Select symptoms from checkboxes, get ranked fault matches
- **Match Scoring:** Each fault shows how many symptoms matched out of total required (e.g. 2/3 means 2 out of 3 symptoms matched)
- **Detailed Repair Advice:** Severity, cost, backup warnings, and actionable repair steps
- **Repair Worthiness Advisor:** Recommends whether to repair, replace, or backup & repair based on cost, severity, and data risk
- **Dynamic Knowledge Base:** Add custom repair cases via UI, stored in `custom_cases.pl`
- **Prolog Concepts Used:** `assertz/1`, `retractall/1`, `findall/3`, `member/2`, `forall/2`, `dynamic/1`, `multifile/1`, backtracking, list processing

## Project Files

| File | Purpose |
|---|---|
| `repair_expert.pl` | Prolog facts, rules, dynamic predicates, and diagnosis engine |
| `app.py` | Python Tkinter graphical interface |
| `custom_cases.pl` | Auto-generated file for custom repair cases (created when user adds cases) |

## Requirements

- **Python 3.x** installed
- **SWI-Prolog** installed and available as `swipl` in the command line

## How to Run

1. Open a terminal in this project folder.
2. Run:

```bash
python3 app.py
```

3. Select **Laptop** or **Phone**.
4. Check the symptoms you observe.
5. Click **Diagnose Now**.
6. View results in the table and detailed advice below.

## Manual Prolog Test

```bash
swipl
?- [repair_expert].
?- run_diagnosis(laptop, [overheating, loud_fan, random_shutdown]).
```

## Sample Scenarios

| Scenario | Symptoms | Expected Fault | Match | Decision |
|---|---|---|---|---|
| Laptop battery | battery_drain, random_shutdown, no_power | Battery Failure | 3/3 | Repair Device |
| Laptop cooling | overheating, loud_fan, slow_performance | Cooling System Problem | 3/4 | Repair Device |
| Laptop storage | boot_failure, clicking_sound, slow_performance | Hard Disk / SSD Failure | 3/3 | Replace Device |
| Phone display | cracked_screen, black_screen, touch_not_working | Display or Touch Panel Damage | 3/3 | Consider Replacing |
| Phone water damage | water_damage, no_power, no_charging | Water Damage | 3/3 | Replace Device |
| Phone storage | storage_full, slow_performance | Storage Overload | 2/2 | Backup Data & Repair |

## Repair Worthiness Advisor

The system goes beyond diagnosis — it also recommends a repair decision using Prolog rules:

```prolog
repair_decision(high, critical, replace_device).
repair_decision(high, high, consider_replacing).
repair_decision(medium, critical, backup_and_repair).
repair_decision(low, low, repair_device).
```

The decision combines **cost level** and **severity** of the fault. If backup is needed, the system upgrades `repair_device` to `backup_and_repair` automatically.

