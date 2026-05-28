# Smart Laptop & Phone Repair Diagnosis Expert System

**Course:** CM2520 - Deductive Reasoning and Logic Programming  
**Backend:** SWI-Prolog  
**Frontend:** Python Tkinter GUI

## Overview

A rule-based expert system that diagnoses common laptop and phone repair issues from user-selected symptoms. The Prolog backend reasons over the symptoms and returns possible faults, confidence scores, severity levels, estimated cost, backup warnings, and repair advice.

## Features

- **Device Selection:** Laptop and Phone support
- **Symptom-based Diagnosis:** Select symptoms from checkboxes, get ranked fault matches
- **Confidence Scoring:** Each fault shows a match percentage based on symptom overlap
- **Detailed Repair Advice:** Severity, cost, backup warnings, and actionable repair steps
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

| Scenario | Symptoms | Expected Fault |
|---|---|---|
| Laptop battery | battery_drain, random_shutdown, no_power | Battery Failure (100%) |
| Laptop cooling | overheating, loud_fan, slow_performance | Cooling System Problem (75%) |
| Laptop storage | boot_failure, clicking_sound, slow_performance | Hard Disk / SSD Failure (100%) |
| Phone display | cracked_screen, black_screen, touch_not_working | Display or Touch Panel Damage (100%) |
| Phone water damage | water_damage, no_power, no_charging | Water Damage (100%) |
| Phone storage | storage_full, slow_performance | Storage Overload (100%) |
