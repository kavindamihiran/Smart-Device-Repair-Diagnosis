# Smart Laptop & Phone Repair Diagnosis Expert System

**Course:** CM2520 - Deductive Reasoning and Logic Programming  
**Backend:** SWI-Prolog  
**Frontend:** Python Tkinter GUI

## Overview

A rule-based expert system that diagnoses common laptop and phone repair issues from user-selected symptoms. The Prolog backend reasons over the symptoms and returns possible faults, confidence scores, severity levels, estimated cost, and repair advice.

## Features

- **Device Selection:** Laptop and Phone support
- **Symptom-based Diagnosis:** Select symptoms from checkboxes, get ranked fault matches
- **Match Scoring:** Each fault shows how many symptoms matched out of total required (e.g. 2/3 means 2 out of 3 symptoms matched)
- **Detailed Repair Advice:** Severity, cost, and actionable repair steps
- **Easy Manual Updates:** Add new faults in `repair_faults.pl` and their symptoms in `repair_rules.pl`
- **Prolog Concepts Used:** `assertz/1`, `retractall/1`, `findall/3`, `member/2`, `forall/2`, `dynamic/1`, backtracking, list processing

## Project Files

| File | Purpose |
|---|---|
| `repair_expert.pl` | Main Prolog entry file that loads all backend modules |
| `repair_devices_symptoms.pl` | Supported devices and symptom dictionary |
| `repair_faults.pl` | Fault details, severity, cost, and advice |
| `repair_rules.pl` | Diagnostic rules that connect faults to required symptoms |
| `repair_engine.pl` | Working memory, symptom matching, scoring, and ranking logic |
| `repair_io.pl` | Terminal output and Python UI output formatter |
| `app.py` | Python Tkinter graphical interface |

## Prolog Module Structure

The backend is split into small Prolog files to make the system easier to understand and explain. `repair_expert.pl` is still the only file that needs to be loaded directly. It uses `ensure_loaded/1` to load the other modules.

```text
repair_expert.pl
  -> repair_devices_symptoms.pl
  -> repair_faults.pl
  -> repair_rules.pl
  -> repair_engine.pl
  -> repair_io.pl
```

Main diagnosis flow:

```text
run_diagnosis(Device, Symptoms)
  -> clear_observations
  -> add_symptom_list
  -> diagnose
  -> print_results
```

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

You can also run a diagnosis directly from the terminal without opening the Prolog prompt:

```bash
swipl -q -s repair_expert.pl -g "run_diagnosis(laptop, [overheating,loud_fan,random_shutdown])"
```

## Sample Scenarios

| Scenario | Symptoms | Expected Fault | Match | Severity |
|---|---|---|---|---|
| Laptop battery | battery_drain, random_shutdown, no_power | Battery Failure | 3/3 | high |
| Laptop cooling | overheating, loud_fan, slow_performance | Cooling System Problem | 3/4 | high |
| Laptop power and heat | battery_drain, overheating | Power and Thermal Issue | 2/4 | high |
| Laptop boot instability | overheating, boot_failure | Thermal Boot Instability | 2/4 | high |
| Laptop storage | boot_failure, clicking_sound, slow_performance | Hard Disk / SSD Failure | 3/3 | critical |
| Phone display | cracked_screen, black_screen, touch_not_working | Display or Touch Panel Damage | 3/3 | high |
| Phone power and heat | battery_drain, overheating | Phone Power and Thermal Issue | 2/4 | high |
| Phone liquid display | water_damage, black_screen | Liquid Display Damage | 2/4 | critical |
| Phone water damage | water_damage, no_power, no_charging | Water Damage | 3/3 | critical |
| Phone storage | storage_full, slow_performance | Storage Overload | 2/2 | medium |
