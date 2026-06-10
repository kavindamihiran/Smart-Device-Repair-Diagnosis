# Smart Laptop & Phone Repair Diagnosis Expert System

**Course:** CM2520 - Deductive Reasoning and Logic Programming  
**Backend:** SWI-Prolog  
**Frontend:** Python Tkinter GUI

## Overview

A rule-based expert system that diagnoses common laptop and phone repair issues from user-selected symptoms. The Prolog backend reasons over the symptoms and returns possible faults, weighted scores, severity levels, estimated cost, and repair advice.

For a complete explanation of the architecture, every predicate and Python
function, scoring calculations, execution flow, runtime administration, and
runnable examples, see
[`PROJECT_DOCUMENTATION.md`](PROJECT_DOCUMENTATION.md).

## Features

- **Device Selection:** Laptop and Phone support
- **Symptom-based Diagnosis:** Select symptoms from checkboxes, get ranked fault matches
- **Match Scoring:** Each fault shows how many symptoms matched out of total required (e.g. 2/3 means 2 out of 3 symptoms matched)
- **Detailed Repair Advice:** Severity, cost, and actionable repair steps
- **Dynamic Knowledge Base:** Add custom repair cases from the UI, stored in `custom_cases.pl`
- **Manual Updates:** You can also add new faults in `repair_faults.pl` and their symptoms in `repair_rules.pl`
- **Prolog Concepts Used:** facts, rules, recursion, lists, custom recursive
  member/append/length predicates, cut, negation, arithmetic, backtracking,
  dynamic facts, `findall/3`, `bagof/3`, `setof/3`, `call/1`,
  `fail`, and `forall/2`

## Project Files

| File | Purpose |
|---|---|
| `repair_expert.pl` | Main Prolog entry file that loads all backend modules |
| `repair_devices_symptoms.pl` | Supported devices and symptom dictionary |
| `repair_faults.pl` | Fault details, severity, cost, and advice |
| `repair_rules.pl` | Diagnostic rules that connect faults to required symptoms |
| `repair_engine.pl` | Working memory, symptom matching, scoring, and ranking logic |
| `repair_io.pl` | Terminal output and Python UI output formatter |
| `repair_admin.pl` | Predicates for adding/removing custom repair cases |
| `app.py` | Python Tkinter graphical interface |
| `custom_cases.pl` | Auto-generated file for custom repair cases |

## Prolog Module Structure

The backend is split into small Prolog files to make the system easier to understand and explain. `repair_expert.pl` is still the only file that needs to be loaded directly. It uses `ensure_loaded/1` to load the other modules.

```text
repair_expert.pl
  -> repair_devices_symptoms.pl
  -> repair_faults.pl
  -> repair_rules.pl
  -> repair_engine.pl
  -> repair_io.pl
  -> repair_admin.pl
  -> custom_cases.pl, if it exists
```

Main diagnosis flow:

```text
run_diagnosis(Device, Symptoms)
  -> clear_observations
  -> add_symptom_list
  -> diagnose
  -> print_terminal_results
```

`run_diagnosis/2` prints readable terminal output. The Python interface uses `run_diagnosis_for_ui/2`, which prints machine-readable rows for `app.py`.

## Where Prolog Concepts Are Used

| Existing file | Main concepts |
|---|---|
| `repair_engine.pl` | Recursion, `[H|T]`, `repair_member/2`, `repair_append/3`, `repair_length/2`, cut, negation, `findall/3`, arithmetic, comparisons, if-then-else, sorting |
| `repair_admin.pl` | `assertz/1`, `retractall/1`, and recursive list deletion |
| `repair_io.pl` | `forall/2`, `call/1`, `fail`, `bagof/3`, `setof/3`, formatted output |

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

Some useful concept queries:

```prolog
?- repair_member(overheating, [no_power, overheating]).
?- repair_append([overheating], [loud_fan], Combined).
?- repair_length([no_power, overheating, loud_fan], Length).
?- delete_from_list(no_power, [no_power, overheating], Remaining).
?- faults_by_severity(laptop, Severity, Faults).
?- sorted_faults(phone, Faults).
?- fault_info(battery_failure, Device, Label, Severity, Cost, Advice).
```

## Sample Scenarios

| Scenario | Symptoms | Expected Fault | Match | Severity |
|---|---|---|---|---|
| Laptop battery | battery_drain, random_shutdown, no_power | Battery Failure | 3/3 | high |
| Laptop cooling | overheating, loud_fan, slow_performance | Cooling System Problem | 3/4 | high |
| Laptop power and heat | battery_drain, overheating | Power and Thermal Issue | 2/4 | high |
| Laptop boot instability | overheating, boot_failure | Thermal Boot Instability | 2/4 | high |
| Laptop storage | boot_failure, clicking_sound, random_shutdown, blue_screen | Hard Disk / SSD Failure | 4/4 | critical |
| Phone display | cracked_screen, black_screen, touch_not_working | Display or Touch Panel Damage | 3/3 | high |
| Phone power and heat | battery_drain, overheating | Charging IC or Battery Circuit Issue | 2/3 | high |
| Phone liquid display | water_damage, black_screen | Liquid Display Damage | 2/5 | critical |
| Phone water damage | water_damage, no_power, no_charging | Water Damage | 3/3 | critical |
| Phone storage | storage_full, slow_performance | Storage Overload | 2/2 | medium |
