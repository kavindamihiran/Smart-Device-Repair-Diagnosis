# Smart Device Repair Diagnosis - Complete Project Guide

This document explains the complete project as it currently exists in the
repository. It is intended for students, developers, demonstrators, and anyone
who needs to understand, run, explain, test, or extend the system.

The source code is the final authority. This guide describes the current
`fault_info/6` design and current scoring algorithm.

## Table of Contents

1. [Project Summary](#1-project-summary)
2. [Requirements and Quick Start](#2-requirements-and-quick-start)
3. [System Architecture](#3-system-architecture)
4. [Important Prolog Basics](#4-important-prolog-basics)
5. [Project Files](#5-project-files)
6. [Main Loader: repair_expert.pl](#6-main-loader-repair_expertpl)
7. [Devices and Symptoms](#7-devices-and-symptoms)
8. [Fault Information and Diagnostic Rules](#8-fault-information-and-diagnostic-rules)
9. [Diagnosis Engine](#9-diagnosis-engine)
10. [Console and UI Output](#10-console-and-ui-output)
11. [Runtime Knowledge Administration](#11-runtime-knowledge-administration)
12. [Python Tkinter Application](#12-python-tkinter-application)
13. [Complete Diagnosis Walkthrough](#13-complete-diagnosis-walkthrough)
14. [Adding and Removing Repair Cases](#14-adding-and-removing-repair-cases)
15. [Useful Queries and Examples](#15-useful-queries-and-examples)
16. [How the Main Predicates Differ](#16-how-the-main-predicates-differ)
17. [Troubleshooting](#17-troubleshooting)
18. [Current Limitations and Improvement Ideas](#18-current-limitations-and-improvement-ideas)
19. [Short Explanation for a Demonstration](#19-short-explanation-for-a-demonstration)
20. [Glossary](#20-glossary)

---

## 1. Project Summary

This is a rule-based expert system for diagnosing common laptop and phone
faults.

The user:

1. Selects a device: `laptop` or `phone`.
2. Selects one or more observed symptoms.
3. Starts a diagnosis.
4. Receives ranked possible faults.
5. Sees the match count, score, severity, cost category, matched symptoms, and
   repair advice.

The project contains two main layers:

- **SWI-Prolog backend:** stores repair knowledge and performs reasoning.
- **Python Tkinter frontend:** collects input and displays results.

The current knowledge base contains:

| Item | Count |
|---|---:|
| Supported devices | 2 |
| Laptop symptoms | 15 |
| Phone symptoms | 15 |
| Laptop faults | 19 |
| Phone faults | 21 |

The system is an expert system because domain knowledge is represented as
facts and rules rather than as a trained machine-learning model.

---

## 2. Requirements and Quick Start

### 2.1 Requirements

- Python 3
- Tkinter, normally included with standard Python installations
- SWI-Prolog available through the `swipl` command

Check the installations:

```powershell
python --version
swipl --version
```

### 2.2 Run the graphical application

From the project folder:

```powershell
python app.py
```

Then:

1. Select Laptop or Phone.
2. Select symptoms.
3. Click **Diagnose Now**.
4. Select a result row to view its details.

### 2.3 Run Prolog interactively

```powershell
swipl
```

Load the main file:

```prolog
?- [repair_expert].
```

Run a diagnosis without using the output predicate that calls `halt/0`:

```prolog
?- clear_observations,
   add_symptom_list([overheating, loud_fan, random_shutdown]),
   diagnose(laptop, Results).
```

### 2.4 Run one terminal diagnosis directly

```powershell
swipl -q -s repair_expert.pl -g "run_diagnosis(laptop, [overheating,loud_fan,random_shutdown])"
```

`run_diagnosis/2` calls `halt/0`, so it is best for a one-command terminal
process. Inside an interactive Prolog session, use `diagnose/2` if you do not
want Prolog to exit.

---

## 3. System Architecture

### 3.1 File loading structure

```text
repair_expert.pl
  |
  +-- repair_devices_symptoms.pl
  +-- repair_faults.pl
  +-- repair_rules.pl
  +-- repair_engine.pl
  +-- repair_io.pl
  +-- repair_admin.pl
  +-- custom_cases.pl          only when this optional file exists
```

### 3.2 Diagnosis call structure

```text
Python button click
  |
  +-- RepairDiagnosisApp.diagnose()
        |
        +-- selected_symptoms()
        +-- run_prolog_diagnosis(Device, Symptoms)
              |
              +-- starts a new swipl process
              +-- run_diagnosis_for_ui/2
                    |
                    +-- clear_observations/0
                    +-- add_symptom_list/1
                    +-- diagnose/2
                    |     |
                    |     +-- make_result/2
                    |           |
                    |           +-- likely_fault/6
                    |           |     |
                    |           |     +-- score_fault/6
                    |           |
                    |           +-- fault_info/6
                    |
                    +-- print_ui_results/1
                    +-- halt/0
```

### 3.3 Data flow

```text
Selected symptoms
    -> temporary observed_symptom/1 facts
    -> comparison with fault_symptoms/3 rules
    -> match and missing lists
    -> score calculation
    -> score threshold
    -> fault_info/6 lookup
    -> sorting
    -> terminal text or pipe-separated UI text
    -> Python dictionaries
    -> Tkinter result table and detail boxes
```

---

## 4. Important Prolog Basics

### 4.1 Facts

A fact states that something is true:

```prolog
device(laptop).
```

This means that `laptop` is a supported device.

### 4.2 Rules

A rule has a head and a body:

```prolog
likely_fault(Device, Fault, Score, MatchCount, Total, Matched) :-
    score_fault(Device, Fault, Score, MatchCount, Total, Matched),
    Score >= 50.
```

Read `:-` as **if**:

> A fault is likely if the fault can be scored and its score is at least 50.

### 4.3 Queries

A query asks Prolog to prove something:

```prolog
?- device(laptop).
true.
```

```prolog
?- device(Device).
Device = laptop ;
Device = phone.
```

The semicolon requests another solution through backtracking.

### 4.4 Atoms, variables, strings, and numbers

```prolog
laptop             % atom
cooling_problem    % atom
Device             % variable because it starts with an uppercase letter
_                  % anonymous variable
"Cooling Problem"  % string
50                 % number
```

Atoms such as `cooling_problem` are internal identifiers. Strings such as
`"Cooling System Problem"` are readable UI text.

### 4.5 Lists

```prolog
[overheating, loud_fan, random_shutdown]
```

A list can be separated into its head and tail:

```prolog
[Head|Tail]
```

For the list above:

```prolog
Head = overheating
Tail = [loud_fan, random_shutdown]
```

This pattern is used by the recursive predicates in `repair_engine.pl` and
`repair_admin.pl`.

### 4.6 Predicate name and arity

`fault_info/6` means:

- Predicate name: `fault_info`
- Number of arguments: 6

`clear_observations/0` has no arguments.

### 4.7 Unification

Prolog uses `=` to make terms match:

```prolog
?- Device = laptop.
Device = laptop.
```

`=` does not perform arithmetic. Arithmetic evaluation uses `is`:

```prolog
?- X is 2 + 3.
X = 5.
```

### 4.8 Backtracking

When a predicate has multiple matching facts or rules, Prolog can return
multiple solutions:

```prolog
?- fault_info(Fault, laptop, _, high, _, _).
```

Prolog searches the facts in order and returns each matching laptop fault with
high severity.

---

## 5. Project Files

| File | Responsibility |
|---|---|
| [`repair_expert.pl`](repair_expert.pl) | Main loader and dynamic/multifile declarations |
| [`repair_devices_symptoms.pl`](repair_devices_symptoms.pl) | Supported devices and symptom labels |
| [`repair_faults.pl`](repair_faults.pl) | Fault labels, severity, cost, and advice |
| [`repair_rules.pl`](repair_rules.pl) | Symptoms required by each fault |
| [`repair_engine.pl`](repair_engine.pl) | Working memory, matching, scoring, filtering, and sorting |
| [`repair_io.pl`](repair_io.pl) | Terminal output, UI output, and knowledge-base queries |
| [`repair_admin.pl`](repair_admin.pl) | Runtime add, remove, edit, and term conversion predicates |
| [`app.py`](app.py) | Tkinter interface and SWI-Prolog subprocess integration |
| `custom_cases.pl` | Optional generated file containing persistent custom facts |
| [`README.md`](README.md) | Short setup and project overview |
| [`Prolog_Learning_Guide.md`](Prolog_Learning_Guide.md) | Older learning material; some sections describe an earlier design |

Important: the current source uses `fault_info/6`. Any older documentation that
mentions `fault_info/7`, backup flags, or `repair_decision.pl` describes a
previous version and should not be used to explain the current execution.

---

## 6. Main Loader: repair_expert.pl

### 6.1 Dynamic declarations

```prolog
:- dynamic observed_symptom/1.
:- dynamic fault_info/6.
:- dynamic fault_symptoms/3.
```

A dynamic predicate can be changed while Prolog is running with predicates
such as:

- `assertz/1`
- `retract/1`
- `retractall/1`

Why each predicate is dynamic:

| Predicate | Reason |
|---|---|
| `observed_symptom/1` | Selected symptoms are inserted and cleared for each diagnosis |
| `fault_info/6` | Custom fault details can be added or removed at runtime |
| `fault_symptoms/3` | Custom rules can be added, removed, or edited at runtime |

### 6.2 Multifile declarations

```prolog
:- multifile fault_info/6.
:- multifile fault_symptoms/3.
```

`multifile` allows clauses for one predicate to be spread across different
files.

For example:

- Standard `fault_info/6` facts are in `repair_faults.pl`.
- Custom `fault_info/6` facts may be in `custom_cases.pl`.

### 6.3 Loading project files

```prolog
:- ensure_loaded('repair_devices_symptoms.pl').
:- ensure_loaded('repair_faults.pl').
:- ensure_loaded('repair_rules.pl').
:- ensure_loaded('repair_engine.pl').
:- ensure_loaded('repair_io.pl').
:- ensure_loaded('repair_admin.pl').
```

`ensure_loaded/1` loads each source file and avoids unnecessary duplicate
loading.

Only `repair_expert.pl` needs to be loaded directly:

```prolog
?- [repair_expert].
```

### 6.4 Loading optional custom cases

```prolog
:- initialization(load_custom_cases).

load_custom_cases :-
    exists_file('custom_cases.pl'),
    !,
    consult('custom_cases.pl').
load_custom_cases.
```

Execution:

1. `initialization/1` runs `load_custom_cases/0` during startup.
2. `exists_file/1` checks whether `custom_cases.pl` exists.
3. If it exists, the cut `!` commits to the first clause.
4. `consult/1` loads its facts.
5. If it does not exist, the second empty clause succeeds.

The second clause prevents startup from failing when no custom case file has
been created.

---

## 7. Devices and Symptoms

The file `repair_devices_symptoms.pl` defines `device/1` and `symptom/3`.

### 7.1 `device/1`

```prolog
device(laptop).
device(phone).
```

Example:

```prolog
?- device(Device).
Device = laptop ;
Device = phone.
```

### 7.2 `symptom/3`

Structure:

```prolog
symptom(Device, SymptomAtom, HumanReadableLabel).
```

Example:

```prolog
symptom(laptop, loud_fan, "Fan is very loud").
```

Arguments:

| Argument | Meaning |
|---|---|
| `Device` | Device category |
| `SymptomAtom` | Internal identifier used in rules and queries |
| `HumanReadableLabel` | Text intended for a person |

### 7.3 Laptop symptoms

| Atom | Display label |
|---|---|
| `no_power` | Does not power on |
| `no_charging` | Does not charge |
| `battery_drain` | Battery drains quickly |
| `random_shutdown` | Random shutdown |
| `overheating` | Overheating |
| `loud_fan` | Fan is very loud |
| `black_screen` | Black screen |
| `display_flicker` | Display flickering |
| `slow_performance` | Slow performance |
| `boot_failure` | Boot failure |
| `clicking_sound` | Clicking sound from storage |
| `keyboard_not_working` | Keyboard not working |
| `wifi_not_working` | Wi-Fi not working |
| `virus_popups` | Unwanted popups / suspicious apps |
| `blue_screen` | Blue screen / system crash |

### 7.4 Phone symptoms

| Atom | Display label |
|---|---|
| `no_power` | Does not power on |
| `no_charging` | Does not charge |
| `battery_drain` | Battery drains quickly |
| `random_shutdown` | Random shutdown |
| `overheating` | Overheating |
| `cracked_screen` | Cracked screen |
| `black_screen` | Black screen |
| `touch_not_working` | Touch not working |
| `slow_performance` | Slow performance |
| `storage_full` | Storage full |
| `wifi_not_working` | Wi-Fi not working |
| `camera_not_working` | Camera not working |
| `speaker_not_working` | Speaker not working |
| `water_damage` | Water damage |
| `boot_loop` | Phone stuck in boot loop |

### 7.5 Query examples

List every laptop symptom:

```prolog
?- symptom(laptop, Atom, Label).
```

Check whether a symptom is valid for a phone:

```prolog
?- symptom(phone, water_damage, Label).
Label = "Water damage".
```

The Python UI currently contains a separate `SYMPTOMS` dictionary with the
same atoms and labels. If a symptom is added, both the Prolog file and
`app.py` must currently be updated for it to appear in the UI.

---

## 8. Fault Information and Diagnostic Rules

The system separates descriptive information from matching rules.

### 8.1 `fault_info/6`

Stored in `repair_faults.pl`:

```prolog
fault_info(Fault, Device, Label, Severity, Cost, Advice).
```

Example:

```prolog
fault_info(cooling_problem, laptop, "Cooling System Problem", high, medium,
    "Clean the fan, replace thermal paste, and check air vents.").
```

Arguments:

| Argument | Meaning |
|---|---|
| `Fault` | Internal unique fault atom |
| `Device` | `laptop` or `phone` |
| `Label` | Human-readable fault name |
| `Severity` | `low`, `medium`, `high`, or `critical` |
| `Cost` | `low`, `medium`, or `high` |
| `Advice` | Repair recommendation string |

### 8.2 `fault_symptoms/3`

Stored in `repair_rules.pl`:

```prolog
fault_symptoms(Device, Fault, RequiredSymptoms).
```

Example:

```prolog
fault_symptoms(laptop, cooling_problem,
    [overheating, loud_fan, random_shutdown, slow_performance]).
```

This means those four symptoms are the evidence associated with the cooling
problem rule. A user does not need to select all four symptoms. The scoring
engine calculates a partial match.

### 8.3 Why the data is separated

`fault_info/6` answers:

> What is this fault, how serious is it, how costly is it, and what should the
> user do?

`fault_symptoms/3` answers:

> Which symptoms provide evidence for this fault?

`make_result/2` joins the two predicates through the same `Fault` and `Device`.
A fault must have both a matching rule and descriptive information to appear
as a complete diagnosis result.

### 8.4 Laptop fault catalog

| Fault atom | Label | Severity | Cost | Required symptoms |
|---|---|---|---|---|
| `battery_failure` | Battery Failure | high | medium | `battery_drain`, `random_shutdown`, `no_power` |
| `charger_or_port_issue` | Charger or Charging Port Issue | medium | low | `no_charging` |
| `cooling_problem` | Cooling System Problem | high | medium | `overheating`, `loud_fan`, `random_shutdown`, `slow_performance` |
| `display_damage` | Display Cable or Panel Damage | high | high | `black_screen`, `display_flicker` |
| `storage_failure` | Hard Disk / SSD Failure | critical | high | `boot_failure`, `clicking_sound`, `random_shutdown`, `blue_screen` |
| `malware_infection` | Malware or Unwanted Software | medium | low | `slow_performance`, `virus_popups`, `blue_screen` |
| `ram_or_os_crash` | RAM Issue or Operating System Crash | high | medium | `blue_screen`, `random_shutdown`, `boot_failure` |
| `keyboard_fault` | Keyboard Hardware Fault | medium | medium | `keyboard_not_working` |
| `wifi_adapter_fault` | Wi-Fi Adapter or Driver Fault | medium | low | `wifi_not_working` |
| `power_thermal_issue` | Power and Thermal Issue | high | medium | `battery_drain`, `overheating`, `loud_fan`, `random_shutdown` |
| `thermal_boot_instability` | Thermal Boot Instability | high | medium | `overheating`, `loud_fan`, `boot_failure`, `blue_screen` |
| `storage_or_system_crash` | Storage or System Crash | critical | high | `clicking_sound`, `random_shutdown`, `blue_screen`, `boot_failure` |
| `battery_charging_issue` | Battery and Charging Issue | high | medium | `battery_drain`, `no_charging`, `random_shutdown` |
| `motherboard_power_issue` | Motherboard Power Issue | critical | high | `no_power`, `no_charging`, `random_shutdown` |
| `display_or_graphics_issue` | Display or Graphics Issue | high | high | `black_screen`, `display_flicker`, `blue_screen` |
| `system_performance_issue` | System Performance Issue | medium | low | `slow_performance`, `boot_failure`, `virus_popups` |
| `os_boot_problem` | Operating System Boot Problem | high | medium | `boot_failure`, `blue_screen`, `slow_performance` |
| `software_crash_or_malware` | Software Crash or Malware Issue | medium | low | `virus_popups`, `slow_performance`, `blue_screen` |
| `power_display_startup_issue` | Power or Display Startup Issue | critical | high | `no_power`, `black_screen`, `no_charging` |

### 8.5 Phone fault catalog

| Fault atom | Label | Severity | Cost | Required symptoms |
|---|---|---|---|---|
| `phone_battery_failure` | Phone Battery Failure | high | medium | `battery_drain`, `random_shutdown`, `no_power` |
| `phone_charging_port_issue` | Charging Port Issue | medium | low | `no_charging` |
| `phone_display_damage` | Display or Touch Panel Damage | high | high | `cracked_screen`, `black_screen`, `touch_not_working` |
| `phone_storage_overload` | Storage Overload | medium | low | `storage_full`, `slow_performance` |
| `phone_water_damage` | Water Damage | critical | high | `water_damage`, `no_power`, `no_charging` |
| `phone_camera_fault` | Camera Module Fault | medium | medium | `camera_not_working` |
| `phone_speaker_fault` | Speaker or Audio IC Fault | medium | medium | `speaker_not_working` |
| `phone_network_fault` | Network / Wi-Fi Fault | medium | low | `wifi_not_working` |
| `phone_boot_loop_fault` | Boot Loop / Firmware Issue | critical | medium | `boot_loop`, `random_shutdown` |
| `phone_power_thermal_issue` | Phone Power and Thermal Issue | high | medium | `battery_drain`, `overheating`, `random_shutdown`, `no_power` |
| `phone_physical_display_power_issue` | Physical Display and Power Issue | high | high | `cracked_screen`, `no_power`, `battery_drain`, `random_shutdown` |
| `phone_liquid_display_issue` | Liquid Display Damage | critical | high | `water_damage`, `no_charging`, `no_power`, `black_screen`, `touch_not_working` |
| `phone_battery_charging_issue` | Phone Battery and Charging Issue | high | medium | `battery_drain`, `no_charging`, `random_shutdown` |
| `phone_overheating_battery_issue` | Phone Overheating Battery Issue | high | medium | `battery_drain`, `overheating`, `random_shutdown` |
| `phone_screen_touch_issue` | Screen and Touch Issue | high | high | `black_screen`, `touch_not_working`, `cracked_screen` |
| `phone_software_performance_issue` | Software Performance Issue | medium | low | `slow_performance`, `storage_full`, `boot_loop` |
| `phone_charging_ic_issue` | Charging IC or Battery Circuit Issue | high | medium | `no_charging`, `overheating`, `battery_drain` |
| `phone_camera_software_issue` | Camera Software or Storage Issue | medium | low | `camera_not_working`, `storage_full`, `slow_performance` |
| `phone_audio_software_issue` | Audio Software or Speaker Issue | medium | low | `speaker_not_working`, `slow_performance` |
| `phone_network_software_issue` | Network Settings or Wi-Fi Issue | medium | low | `wifi_not_working`, `slow_performance` |
| `phone_firmware_storage_issue` | Firmware and Storage Issue | critical | medium | `boot_loop`, `storage_full`, `slow_performance` |

The full repair advice text for each row is stored in `repair_faults.pl` and is
retrieved automatically by `make_result/2`.

---

## 9. Diagnosis Engine

The file `repair_engine.pl` contains the main reasoning logic.

### 9.1 Working memory: `observed_symptom/1`

Selected symptoms are temporarily stored as dynamic facts:

```prolog
observed_symptom(overheating).
observed_symptom(loud_fan).
```

These facts are working memory for the current Prolog process.

### 9.2 `clear_observations/0`

```prolog
clear_observations :-
    retractall(observed_symptom(_)).
```

`retractall/1` removes every matching fact.

Example:

```prolog
?- clear_observations.
true.
```

This prevents symptoms from a previous diagnosis from affecting the next one.

### 9.3 `add_observed_symptom/1`

```prolog
add_observed_symptom(Symptom) :-
    observed_symptom(Symptom),
    !.
add_observed_symptom(Symptom) :-
    assertz(observed_symptom(Symptom)).
```

Execution:

1. If the symptom already exists, the first clause succeeds.
2. The cut prevents Prolog from backtracking into the insertion clause.
3. Otherwise, `assertz/1` adds the symptom.

This prevents duplicate observed facts.

Example:

```prolog
?- clear_observations,
   add_observed_symptom(overheating),
   add_observed_symptom(overheating),
   findall(X, observed_symptom(X), Symptoms).

Symptoms = [overheating].
```

### 9.4 `add_symptom_list/1`

```prolog
add_symptom_list([]).
add_symptom_list([H|T]) :-
    add_observed_symptom(H),
    add_symptom_list(T).
```

This is recursive list processing.

Base case:

```prolog
add_symptom_list([]).
```

An empty list requires no work.

Recursive case:

```prolog
add_symptom_list([H|T])
```

Add the head `H`, then recursively process the tail `T`.

Example trace:

```text
add_symptom_list([overheating, loud_fan])
  add overheating
  add_symptom_list([loud_fan])
    add loud_fan
    add_symptom_list([])
      stop
```

### 9.5 `repair_member/2`

```prolog
repair_member(Item, [Item|_]).
repair_member(Item, [_|Tail]) :-
    repair_member(Item, Tail).
```

This is the project's recursive version of built-in `member/2`.

First clause:

- The item is the list head, so the predicate succeeds.

Second clause:

- Ignore the current head.
- Search recursively in the tail.

Example:

```prolog
?- repair_member(loud_fan, [overheating, loud_fan, no_power]).
true.
```

### 9.6 `repair_append/3`

```prolog
repair_append([], List, List).
repair_append([Head|Tail], List, [Head|CombinedTail]) :-
    repair_append(Tail, List, CombinedTail).
```

This is the project's recursive version of built-in `append/3`.

Example:

```prolog
?- repair_append([overheating], [loud_fan], Combined).
Combined = [overheating, loud_fan].
```

It is used to combine matched and missing symptoms into one classified list.

### 9.7 `repair_length/2`

```prolog
repair_length([], 0).
repair_length([_|Tail], Length) :-
    repair_length(Tail, TailLength),
    Length is TailLength + 1.
```

This is the project's recursive version of built-in `length/2`.

Example:

```prolog
?- repair_length([a, b, c], Length).
Length = 3.
```

The recursion reaches the empty list and then calculates lengths while
returning from recursive calls:

```text
length([]) = 0
length([c]) = 0 + 1
length([b,c]) = 1 + 1
length([a,b,c]) = 2 + 1
```

### 9.8 `matched_symptoms/2`

```prolog
matched_symptoms(Required, Matched) :-
    findall(
        Symptom,
        (
            repair_member(Symptom, Required),
            observed_symptom(Symptom)
        ),
        Matched
    ).
```

`findall/3` has this form:

```prolog
findall(Template, Goal, Results).
```

For each required symptom, the goal checks whether the symptom is also
observed. Every successful symptom is collected into `Matched`.

Example:

```prolog
?- clear_observations,
   add_symptom_list([overheating, random_shutdown]),
   matched_symptoms(
       [overheating, loud_fan, random_shutdown, slow_performance],
       Matched
   ).

Matched = [overheating, random_shutdown].
```

The order follows the fault's required symptom list, not necessarily the
user's selection order.

### 9.9 `missing_symptoms/2`

```prolog
missing_symptoms(Required, Missing) :-
    findall(
        Symptom,
        (
            repair_member(Symptom, Required),
            \+ observed_symptom(Symptom)
        ),
        Missing
    ).
```

`\+ Goal` means **negation as failure**:

> Succeed when Prolog cannot prove `Goal`.

Example using the same observations:

```prolog
Missing = [loud_fan, slow_performance].
```

### 9.10 `score_fault/6`

```prolog
score_fault(Device, Fault, Score, MatchCount, Total, Matched) :-
    fault_symptoms(Device, Fault, Required),
    matched_symptoms(Required, Matched),
    missing_symptoms(Required, Missing),
    repair_append(Matched, Missing, ClassifiedSymptoms),
    repair_length(Matched, MatchCount),
    repair_length(ClassifiedSymptoms, Total),
    Total > 0,
    MatchCount > 0,
    MatchPercent is (MatchCount * 100) // Total,
    EvidenceWeight is min(MatchCount * 50, 100),
    Score is (MatchPercent + EvidenceWeight) // 2.
```

Arguments:

| Argument | Meaning |
|---|---|
| `Device` | Device being diagnosed |
| `Fault` | Candidate fault |
| `Score` | Final integer score |
| `MatchCount` | Number of required symptoms observed |
| `Total` | Total symptoms in that fault rule |
| `Matched` | List of matched symptom atoms |

Execution:

1. Find one `fault_symptoms/3` rule.
2. Build the matched list.
3. Build the missing list.
4. Combine both lists.
5. Count matched symptoms.
6. Count total classified symptoms.
7. Reject an invalid empty rule with `Total > 0`.
8. Reject a fault with no evidence using `MatchCount > 0`.
9. Calculate match completeness.
10. Calculate evidence weight.
11. Average both values.

#### Score formula

```text
MatchPercent  = floor((MatchCount * 100) / Total)
EvidenceWeight = min(MatchCount * 50, 100)
Score          = floor((MatchPercent + EvidenceWeight) / 2)
```

`//` is integer division, so decimal parts are discarded.

The evidence weight is:

| Matched symptoms | Evidence weight |
|---:|---:|
| 1 | 50 |
| 2 or more | 100 |

Example score calculations:

| Match | Match percent | Evidence weight | Final score |
|---|---:|---:|---:|
| 1/1 | 100 | 50 | 75 |
| 1/2 | 50 | 50 | 50 |
| 1/3 | 33 | 50 | 41 |
| 1/4 | 25 | 50 | 37 |
| 2/3 | 66 | 100 | 83 |
| 2/4 | 50 | 100 | 75 |
| 2/5 | 40 | 100 | 70 |
| 3/4 | 75 | 100 | 87 |
| 3/3 | 100 | 100 | 100 |

This is not a plain percentage score. It rewards having two or more pieces of
evidence, even when the fault rule contains many symptoms.

Verified example:

```prolog
?- clear_observations,
   add_symptom_list([no_charging]),
   score_fault(laptop, Fault, Score, MatchCount, Total, Matched).
```

Relevant solutions include:

```text
charger_or_port_issue: 1/1 -> score 75
battery_charging_issue: 1/3 -> score 41
motherboard_power_issue: 1/3 -> score 41
power_display_startup_issue: 1/3 -> score 41
```

Only the first one passes the likely-fault threshold.

### 9.11 `likely_fault/6`

```prolog
likely_fault(Device, Fault, Score, MatchCount, Total, Matched) :-
    score_fault(Device, Fault, Score, MatchCount, Total, Matched),
    Score >= 50.
```

This predicate filters scored faults.

It does not:

- Clear old observations.
- Add a symptom list.
- Retrieve labels, severity, cost, or advice.
- Sort all results.
- Print output.

It assumes observations have already been stored.

Example:

```prolog
?- clear_observations,
   add_symptom_list([overheating, loud_fan]),
   likely_fault(laptop, Fault, Score, MatchCount, Total, Matched).
```

Prolog can return multiple faults through backtracking.

### 9.12 Result structure

A complete result is represented as:

```prolog
result(
    Fault,
    Score,
    Label,
    Severity,
    Cost,
    Advice,
    Matched,
    MatchCount,
    Total
)
```

This is a compound term named `result` with nine arguments.

### 9.13 `make_result/2`

```prolog
make_result(Device,
            result(Fault, Score, Label, Severity, Cost, Advice,
                   Matched, MatchCount, Total)) :-
    likely_fault(Device, Fault, Score, MatchCount, Total, Matched),
    fault_info(Fault, Device, Label, Severity, Cost, Advice).
```

This joins:

- Calculated diagnosis information from `likely_fault/6`.
- Descriptive information from `fault_info/6`.

Example:

```prolog
?- clear_observations,
   add_symptom_list([no_charging]),
   make_result(laptop, Result).
```

The result contains all values needed by the terminal and GUI.

### 9.14 `compare_score/3`

`predsort/3` calls this comparator to order two result terms.

Sorting priority:

1. Higher `MatchCount`
2. Higher `Score`
3. Higher `Total`
4. Alphabetical fault atom

The comparator returns:

- `'<'` when result A should appear before result B.
- `'>'` when result B should appear before result A.

Important: despite its name, `compare_score/3` prioritizes match count before
score.

### 9.15 `diagnose/2`

```prolog
diagnose(Device, ResultsSorted) :-
    findall(Result, make_result(Device, Result), Results),
    list_to_set(Results, Unique),
    predsort(compare_score, Unique, ResultsSorted).
```

Execution:

1. `findall/3` collects every complete likely result.
2. `list_to_set/2` removes exact duplicate result terms.
3. `predsort/3` sorts the unique results.

`diagnose/2` returns data but does not print or halt.

Example:

```prolog
?- clear_observations,
   add_symptom_list([water_damage, black_screen]),
   diagnose(phone, Results).
```

Verified result:

```prolog
Results = [
    result(
        phone_liquid_display_issue,
        70,
        "Liquid Display Damage",
        critical,
        high,
        "Power off immediately. Do not charge. Clean the board and inspect the display connector and panel.",
        [water_damage, black_screen],
        2,
        5
    )
].
```

---

## 10. Console and UI Output

The file `repair_io.pl` provides entry points and output helpers.

### 10.1 `run_diagnosis/2`

```prolog
run_diagnosis(Device, Symptoms) :-
    clear_observations,
    add_symptom_list(Symptoms),
    diagnose(Device, Results),
    print_terminal_results(Results),
    halt.
```

This is the complete readable terminal workflow.

It:

1. Clears previous observations.
2. Adds the supplied symptoms.
3. Calculates sorted results.
4. Prints readable output.
5. Ends the Prolog process.

Example:

```prolog
run_diagnosis(laptop, [overheating, loud_fan, random_shutdown]).
```

### 10.2 `run_diagnosis_for_ui/2`

```prolog
run_diagnosis_for_ui(Device, Symptoms) :-
    clear_observations,
    add_symptom_list(Symptoms),
    diagnose(Device, Results),
    print_ui_results(Results),
    halt.
```

This performs the same diagnosis, but prints machine-readable lines for
Python.

Example output:

```text
RESULT|phone_storage_overload|100|2|2|medium|low|Storage Overload|Delete unnecessary files, clear app cache, and remove unused apps.|storage_full,slow_performance
```

Field order:

```text
RESULT
| fault atom
| score
| match count
| total symptoms
| severity
| cost
| label
| advice
| matched symptoms
```

### 10.3 `print_terminal_results/1`

Empty-list clause:

```prolog
print_terminal_results([]) :-
    format('No strong fault matched.~n'),
    format('Advice: Try selecting more symptoms.~n').
```

Non-empty clause:

```prolog
print_terminal_results(Results) :-
    forall(member(R, Results), print_terminal_result_line(R)).
```

`forall(Condition, Action)` performs the action for every solution of the
condition.

### 10.4 `print_terminal_result_line/1`

This predicate pattern-matches the `result/9` term, joins matched symptom atoms
with `atomic_list_concat/3`, and prints each field using `format/2`.

Common format controls:

| Control | Meaning |
|---|---|
| `~w` | Write a Prolog term |
| `~s` | Write a string |
| `~d` | Write an integer |
| `~n` | New line |

### 10.5 `print_ui_results/1`

No-result output:

```text
NO_RESULT|No strong fault matched|Try selecting more symptoms|
```

Result output is delegated to `print_ui_result_line/1`.

### 10.6 `print_ui_result_line/1`

```prolog
print_ui_result_line(
    result(Fault, Score, Label, Severity, Cost, Advice,
           Matched, MatchCount, Total)
) :-
    atomic_list_concat(Matched, ',', MatchedText),
    format(
        'RESULT|~w|~d|~d|~d|~w|~w|~w|~s|~s~n',
        [Fault, Score, MatchCount, Total, Severity, Cost,
         Label, Advice, MatchedText]
    ).
```

This predicate:

1. Deconstructs one `result/9` term.
2. Joins matched symptom atoms with commas and no spaces.
3. Prints exactly ten pipe-separated fields.
4. Ends the row with a newline.

The output format is a private contract between Prolog and `app.py`. The
Python parser expects `RESULT` at index 0 and at least ten fields.

### 10.7 `list_all_faults/0`

```prolog
list_all_faults :-
    call(fault_info(Fault, Device, Label, Severity, Cost, _)),
    format(...),
    fail.
list_all_faults.
```

This demonstrates the Prolog **failure-driven loop**:

1. `call/1` executes the constructed goal.
2. One fault is printed.
3. `fail` deliberately fails.
4. Prolog backtracks to find the next `fault_info/6` fact.
5. After all facts are printed, the second clause succeeds.

Example:

```prolog
?- list_all_faults.
```

### 10.8 `faults_by_severity/3`

```prolog
faults_by_severity(Device, Severity, Faults) :-
    bagof(
        Fault,
        Label^Cost^Advice^fault_info(
            Fault, Device, Label, Severity, Cost, Advice
        ),
        Faults
    ).
```

`bagof/3` collects solutions and groups them by free variables. If `Severity`
is unbound, Prolog returns one group for each severity.

The `^` operator existentially quantifies variables that should not create
separate groups:

```prolog
Label^Cost^Advice^Goal
```

Example:

```prolog
?- faults_by_severity(laptop, Severity, Faults).
```

Possible first solution:

```prolog
Severity = critical,
Faults = [
    storage_failure,
    storage_or_system_crash,
    motherboard_power_issue,
    power_display_startup_issue
].
```

Unlike `findall/3`, `bagof/3` fails when there are no solutions.

### 10.9 `sorted_faults/2`

```prolog
sorted_faults(Device, Faults) :-
    setof(
        Fault,
        Label^Severity^Cost^Advice^fault_info(
            Fault, Device, Label, Severity, Cost, Advice
        ),
        Faults
    ).
```

`setof/3`:

- Collects solutions.
- Removes duplicates.
- Sorts the result using Prolog term order.

Example:

```prolog
?- sorted_faults(phone, Faults).
```

This returns the phone fault atoms in alphabetical order.

---

## 11. Runtime Knowledge Administration

The file `repair_admin.pl` demonstrates dynamic knowledge-base modification.

### 11.1 `add_custom_case/7`

```prolog
add_custom_case(Device, Fault, Label, Symptoms, Severity, Cost, Advice) :-
    assertz(fault_info(Fault, Device, Label, Severity, Cost, Advice)),
    assertz(fault_symptoms(Device, Fault, Symptoms)).
```

This adds:

1. One descriptive fault fact.
2. One matching rule.

Example:

```prolog
?- add_custom_case(
       laptop,
       usb_port_failure,
       "USB Port Failure",
       [usb_not_working],
       medium,
       low,
       "Clean, test, or replace the USB port."
   ).
true.
```

This update exists only in the current Prolog process unless it is written to
a source file.

### 11.2 `remove_case/1`

```prolog
remove_case(Fault) :-
    retractall(fault_info(Fault, _, _, _, _, _)),
    retractall(fault_symptoms(_, Fault, _)).
```

This removes every information fact and rule with the supplied fault atom.

Example:

```prolog
?- remove_case(usb_port_failure).
true.
```

`retractall/1` succeeds even when no matching facts exist.

### 11.3 `delete_from_list/3`

This small recursive example removes one occurrence from a list:

```prolog
delete_from_list(Item, [Item|Tail], Tail).
delete_from_list(Item, [Head|Tail], [Head|Remaining]) :-
    delete_from_list(Item, Tail, Remaining).
```

Example:

```prolog
?- delete_from_list(loud_fan,
                    [overheating, loud_fan, no_power],
                    Result).
Result = [overheating, no_power].
```

The first clause removes an item found at the head. The second clause keeps the
head and recursively searches the tail.

### 11.4 Direct fault lookup

No conversion helper is required because `fault_info/6` already returns every
piece of information directly.

```prolog
?- fault_info(
       battery_failure,
       Device,
       Label,
       Severity,
       Cost,
       Advice
   ).
```

Result:

```prolog
Device = laptop,
Label = "Battery Failure",
Severity = high,
Cost = medium,
Advice = "Replace the battery. Also check adapter health and charging cycle count.".
```

---

## 12. Python Tkinter Application

The file `app.py` provides the graphical interface.

### 12.1 Imports

```python
import os
import re
import subprocess
import tkinter as tk
from tkinter import ttk, messagebox
```

| Module | Use |
|---|---|
| `os` | Builds file paths and checks file existence |
| `re` | Sanitizes custom fault and symptom names |
| `subprocess` | Starts SWI-Prolog |
| `tkinter` | Creates the GUI |
| `ttk` | Provides themed widgets |
| `messagebox` | Displays warning, error, and information dialogs |

### 12.2 Path constants

```python
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PROLOG_FILE = os.path.join(BASE_DIR, "repair_expert.pl")
CUSTOM_FILE = os.path.join(BASE_DIR, "custom_cases.pl")
```

These paths are based on the location of `app.py`, so the application can find
its Prolog files even if Python is launched from another current directory.

### 12.3 `SYMPTOMS`

`SYMPTOMS` is a Python dictionary:

```python
{
    "laptop": [("no_power", "Does not power on"), ...],
    "phone": [("no_power", "Does not power on"), ...],
}
```

Each tuple contains:

1. The Prolog symptom atom as a Python string.
2. The readable checkbox label.

This data duplicates `symptom/3` facts from Prolog.

### 12.4 `safe_atom(text)`

```python
def safe_atom(text: str) -> str:
    text = text.lower().strip()
    text = re.sub(r"[^a-z0-9_]+", "_", text)
    text = re.sub(r"_+", "_", text).strip("_")
    return text or "custom_fault"
```

Purpose: convert user text into an unquoted atom-like identifier.

Example:

```python
safe_atom("USB Port Failure!")
```

Result:

```text
usb_port_failure
```

Processing:

1. Convert to lowercase.
2. Remove outer spaces.
3. Replace unsupported character groups with `_`.
4. Collapse repeated underscores.
5. Remove leading and trailing underscores.
6. Return `custom_fault` when nothing remains.

### 12.5 `prolog_list(items)`

```python
def prolog_list(items):
    return "[" + ",".join(items) + "]"
```

Example:

```python
prolog_list(["overheating", "loud_fan"])
```

Result:

```text
[overheating,loud_fan]
```

This function assumes the items are already safe unquoted Prolog atoms.

### 12.6 `run_prolog_diagnosis(device, symptoms)`

This is the main Python-to-Prolog bridge.

It first checks:

```python
if not os.path.exists(PROLOG_FILE):
    raise FileNotFoundError(...)
```

It builds a Prolog goal:

```python
goal = f"run_diagnosis_for_ui({device}, {prolog_list(symptoms)})"
```

Example goal:

```text
run_diagnosis_for_ui(phone, [storage_full,slow_performance])
```

It builds the command as a list:

```python
command = ["swipl", "-q", "-s", PROLOG_FILE, "-g", goal]
```

Meaning:

| Option | Meaning |
|---|---|
| `swipl` | Start SWI-Prolog |
| `-q` | Quiet startup |
| `-s repair_expert.pl` | Load the main Prolog file |
| `-g goal` | Run the supplied goal |

It executes:

```python
subprocess.run(
    command,
    capture_output=True,
    text=True,
    cwd=BASE_DIR,
    timeout=15,
    check=False,
)
```

Important settings:

- `capture_output=True`: captures standard output and error.
- `text=True`: returns strings instead of bytes.
- `cwd=BASE_DIR`: lets Prolog resolve relative project paths.
- `timeout=15`: stops waiting after 15 seconds.
- `check=False`: Python handles a nonzero return code manually.

If Prolog fails:

```python
if completed.returncode != 0:
    raise RuntimeError(...)
```

Output parsing:

1. Split output into lines.
2. Split each line with `|`.
3. Parse `NO_RESULT` or `RESULT`.
4. Store each result as a Python dictionary.

Example result dictionary:

```python
{
    "fault": "phone_storage_overload",
    "score": "100",
    "match_count": "2",
    "match_total": "2",
    "severity": "medium",
    "cost": "low",
    "label": "Storage Overload",
    "advice": "Delete unnecessary files, clear app cache, and remove unused apps.",
    "matched": "storage_full,slow_performance",
}
```

### 12.7 `RepairDiagnosisApp`

```python
class RepairDiagnosisApp(tk.Tk):
```

The class inherits from `tk.Tk`, so each instance is the main application
window.

### 12.8 `__init__`

The constructor:

- Creates the main Tk window.
- Sets title, dimensions, minimum size, and background.
- Creates the selected-device variable.
- Creates the symptom-variable dictionary.
- Builds styles.
- Builds the layout.
- Displays laptop symptoms initially.

The initial device is:

```python
self.device_var = tk.StringVar(value="laptop")
```

### 12.9 `_build_style`

This method configures the `clam` theme and reusable Ttk styles for:

- General frames
- White card frames
- Page title and subtitle
- Card headings
- Buttons
- Checkboxes
- Result tree rows and headings

### 12.10 `_build_layout`

This method creates the full interface:

- Header title and subtitle
- Left device-and-symptom panel
- Device radio buttons
- Scrollable symptom checkboxes
- Diagnose and Clear buttons
- Right diagnosis-results panel
- `Treeview` result table
- Fault summary box
- Matched symptoms box
- Repair advice box
- Add Custom Repair Case button
- Open Project Folder button

The result table columns are:

```text
Match | Score | Fault | Severity | Cost
```

The method also connects events:

- Device radio button -> `render_symptoms`
- Diagnose button -> `diagnose`
- Clear button -> `clear_selection`
- Result selection -> `show_selected_detail`
- Window resizing -> `_resize_results_layout`

### 12.11 `render_symptoms`

```python
def render_symptoms(self):
```

This method:

1. Deletes old checkbox widgets.
2. Clears old Boolean variables.
3. Reads the selected device.
4. Creates a checkbox for every symptom in `SYMPTOMS[device]`.

Changing device therefore replaces the symptom checklist.

### 12.12 `selected_symptoms`

```python
def selected_symptoms(self):
    return [atom for atom, var in self.symptom_vars.items() if var.get()]
```

This list comprehension returns the atom of every checked symptom.

Example:

```python
["overheating", "loud_fan"]
```

### 12.13 `clear_selection`

This method:

- Unchecks every symptom.
- Deletes all result rows.
- Clears all detail boxes.

### 12.14 `_resize_results_layout`

This method changes the visible `Treeview` row count according to available
height:

| Right panel height | Result rows |
|---:|---:|
| Less than 520 | 3 |
| 520 to 649 | 4 |
| 650 or more | 6 |

### 12.15 `_clear_detail_boxes`

This resets the fault name, summary values, symptoms, and advice to placeholder
text.

### 12.16 `diagnose`

This is the GUI diagnosis event handler.

Execution:

1. Read selected symptoms.
2. Show a warning if none are selected.
3. Call `run_prolog_diagnosis`.
4. Show an error dialog if Prolog raises an exception.
5. Delete old result rows.
6. Store result dictionaries in `self.results`.
7. Insert each result into the table.
8. Automatically select the first result.
9. Display the first result's detail.

The table formats match and score as:

```python
f"{match_count}/{match_total}"
f"{score}%"
```

### 12.17 `_severity_color`

This maps severity to a display color:

| Severity | Color |
|---|---|
| low | green |
| medium | amber |
| high | orange |
| critical | red |

Unknown values use the default dark text color.

### 12.18 `show_selected_detail`

This method:

1. Reads the selected table item.
2. Uses its numeric item ID as an index into `self.results`.
3. Updates the fault name.
4. Updates match, score, severity, and cost.
5. Applies the severity color.
6. Displays matched symptoms.
7. Displays repair advice.

### 12.19 `add_custom_case_window`

This creates a child window containing fields for:

- Device
- Fault name
- Comma-separated symptom atoms
- Severity
- Cost
- Advice

`save_case`, a nested function, performs these steps:

1. Sanitize device, fault, severity, cost, and symptom atoms.
2. Replace double quotes in label and advice with single quotes.
3. Require at least one symptom.
4. Open `custom_cases.pl` in append mode.
5. Write one `fault_info/6` fact.
6. Write one `fault_symptoms/3` fact.
7. Show a success message.
8. Close the custom-case window.

Example generated file content:

```prolog
fault_info(usb_port_failure, laptop, "USB Port Failure", medium, low,
    "Clean and test the port.").
fault_symptoms(laptop, usb_port_failure, [usb_not_working]).
```

Each diagnosis launches a fresh Prolog process. During startup,
`repair_expert.pl` consults `custom_cases.pl`, so a saved case becomes
available when the user diagnoses again.

### 12.20 `open_folder_hint`

This does not open Windows Explorer. It displays the project-folder path in an
information dialog.

### 12.21 Application startup

```python
if __name__ == "__main__":
    app = RepairDiagnosisApp()
    app.mainloop()
```

The application starts only when `app.py` is run directly. `mainloop()` begins
Tkinter's event loop and keeps the window responsive.

---

## 13. Complete Diagnosis Walkthrough

This example diagnoses a laptop with:

```prolog
[overheating, loud_fan, random_shutdown]
```

### Step 1: Clear working memory

```prolog
clear_observations
```

All old `observed_symptom/1` facts are removed.

### Step 2: Add the new observations

```prolog
add_symptom_list([overheating, loud_fan, random_shutdown])
```

Runtime facts become:

```prolog
observed_symptom(overheating).
observed_symptom(loud_fan).
observed_symptom(random_shutdown).
```

### Step 3: Examine a candidate rule

For `cooling_problem`:

```prolog
Required = [overheating, loud_fan, random_shutdown, slow_performance]
```

### Step 4: Classify symptoms

```prolog
Matched = [overheating, loud_fan, random_shutdown]
Missing = [slow_performance]
```

### Step 5: Count

```text
MatchCount = 3
Total = 4
```

### Step 6: Calculate score

```text
MatchPercent = (3 * 100) // 4 = 75
EvidenceWeight = min(3 * 50, 100) = 100
Score = (75 + 100) // 2 = 87
```

### Step 7: Apply threshold

```text
87 >= 50
```

Therefore, `cooling_problem` is a likely fault.

### Step 8: Retrieve fault information

`make_result/2` joins the score with:

```prolog
fault_info(cooling_problem, laptop, "Cooling System Problem", high, medium,
    "Clean the fan, replace thermal paste, and check air vents.").
```

### Step 9: Find other matching faults

Backtracking evaluates all laptop fault rules.

### Step 10: Sort results

Verified result order:

```text
1. cooling_problem          score 87, match 3/4
2. power_thermal_issue      score 87, match 3/4
3. thermal_boot_instability score 75, match 2/4
```

The first two tie on match count, score, and total, so their fault atoms are
used as the final alphabetical tie-breaker.

---

## 14. Adding and Removing Repair Cases

### 14.1 Add a temporary case in Prolog

```prolog
?- add_custom_case(
       phone,
       microphone_fault,
       "Microphone Fault",
       [microphone_not_working],
       medium,
       medium,
       "Check app permissions, clean the microphone opening, and test the module."
   ).
true.
```

Verify:

```prolog
?- fault_info(microphone_fault, phone, Label, Severity, Cost, Advice).
```

```prolog
?- fault_symptoms(phone, microphone_fault, Symptoms).
```

This case disappears when that Prolog process ends.

### 14.2 Remove the temporary case

```prolog
?- remove_case(microphone_fault).
true.
```

### 14.3 Add a persistent case through the GUI

Use **Add Custom Repair Case**. The Python application appends facts to
`custom_cases.pl`.

Persistent means that future Prolog processes can load the facts from the
file. It does not mean that Prolog's runtime database is automatically written
to disk by `assertz/1`.

### 14.4 Add a standard case manually

For a permanent source-controlled case:

1. Add or confirm the symptom in `repair_devices_symptoms.pl`.
2. Add its matching Python checkbox entry in `app.py`.
3. Add `fault_info/6` to `repair_faults.pl`.
4. Add `fault_symptoms/3` to `repair_rules.pl`.
5. Reload Prolog or restart the GUI.

Keep the same device and fault atom in both fault predicates.

---

## 15. Useful Queries and Examples

Load the project first:

```prolog
?- [repair_expert].
```

### 15.1 List supported devices

```prolog
?- device(Device).
```

### 15.2 List symptoms for a device

```prolog
?- symptom(laptop, Atom, Label).
```

### 15.3 Inspect one fault

```prolog
?- fault_info(cooling_problem, Device, Label, Severity, Cost, Advice).
```

### 15.4 Inspect one diagnostic rule

```prolog
?- fault_symptoms(laptop, cooling_problem, Symptoms).
```

### 15.5 Test custom list membership

```prolog
?- repair_member(overheating, [no_power, overheating]).
true.
```

### 15.6 Join two lists

```prolog
?- repair_append([overheating], [loud_fan], Combined).
Combined = [overheating, loud_fan].
```

### 15.7 Count a list

```prolog
?- repair_length([no_power, overheating, loud_fan], Length).
Length = 3.
```

### 15.8 Inspect working memory

```prolog
?- clear_observations,
   add_symptom_list([overheating, loud_fan]),
   observed_symptom(Symptom).
```

### 15.9 View matched and missing evidence

```prolog
?- clear_observations,
   add_symptom_list([overheating, loud_fan]),
   fault_symptoms(laptop, cooling_problem, Required),
   matched_symptoms(Required, Matched),
   missing_symptoms(Required, Missing).
```

### 15.10 Score one exact fault

```prolog
?- clear_observations,
   add_symptom_list([overheating, loud_fan]),
   score_fault(
       laptop,
       cooling_problem,
       Score,
       MatchCount,
       Total,
       Matched
   ).
```

Expected:

```prolog
Score = 75,
MatchCount = 2,
Total = 4,
Matched = [overheating, loud_fan].
```

### 15.11 Find every likely fault

```prolog
?- clear_observations,
   add_symptom_list([overheating, loud_fan]),
   likely_fault(laptop, Fault, Score, MatchCount, Total, Matched).
```

Use `;` to request the next solution.

### 15.12 Return all sorted diagnoses

```prolog
?- clear_observations,
   add_symptom_list([storage_full, slow_performance]),
   diagnose(phone, Results).
```

### 15.13 Print all faults

```prolog
?- list_all_faults.
```

### 15.14 Group laptop faults by severity

```prolog
?- faults_by_severity(laptop, Severity, Faults).
```

### 15.15 Get sorted phone fault atoms

```prolog
?- sorted_faults(phone, Faults).
```

### 15.16 Delete one list occurrence

```prolog
?- delete_from_list(a, [a, b, a], Result).
```

### 15.17 Retrieve fault information directly

```prolog
?- fault_info(battery_failure, Device, Label, Severity, Cost, Advice).
```

### 15.18 Test no-result behavior

One observed symptom may be insufficient for every rule that contains it:

```prolog
?- clear_observations,
   add_symptom_list([water_damage]),
   diagnose(phone, Results).
```

`water_damage` matches one symptom out of three for `phone_water_damage` and
one out of five for `phone_liquid_display_issue`. Their scores are below 50,
so this query returns:

```prolog
Results = [].
```

---

## 16. How the Main Predicates Differ

| Predicate | Input | Main purpose | Prints? | Halts? |
|---|---|---|---|---|
| `score_fault/6` | Existing observations and one candidate generated by Prolog | Calculate raw score data | No | No |
| `likely_fault/6` | Existing observations | Return only scores at least 50 | No | No |
| `make_result/2` | Existing observations and device | Join score with fault information | No | No |
| `diagnose/2` | Existing observations and device | Collect, deduplicate, and sort all results | No | No |
| `run_diagnosis/2` | Device and symptom list | Complete terminal workflow | Yes | Yes |
| `run_diagnosis_for_ui/2` | Device and symptom list | Complete Python-facing workflow | Yes | Yes |

### `likely_fault/6` versus `run_diagnosis/2`

`likely_fault/6` is an internal reasoning predicate:

```prolog
?- clear_observations,
   add_symptom_list([overheating, loud_fan]),
   likely_fault(laptop, Fault, Score, MatchCount, Total, Matched).
```

It returns one solution at a time and assumes observations already exist.

`run_diagnosis/2` is a complete entry point:

```prolog
?- run_diagnosis(laptop, [overheating, loud_fan]).
```

It manages observations, diagnoses, prints readable output, and exits Prolog.

### `fault_info/6` versus `fault_symptoms/3`

```prolog
fault_info/6
```

stores what the fault means.

```prolog
fault_symptoms/3
```

stores how the fault is recognized.

### `findall/3`, `bagof/3`, and `setof/3`

| Predicate | No solutions | Grouping | Duplicate removal | Sorting |
|---|---|---|---|---|
| `findall/3` | Returns `[]` | No | No | No |
| `bagof/3` | Fails | Yes | No | No |
| `setof/3` | Fails | Yes | Yes | Yes |

---

## 17. Troubleshooting

### 17.1 Python says `swipl` was not found

SWI-Prolog is missing or its executable directory is not in `PATH`.

Test:

```powershell
swipl --version
```

Restart the terminal after changing `PATH`.

### 17.2 `repair_expert.pl was not found`

Ensure `app.py` and `repair_expert.pl` remain in the same project folder.

### 17.3 Prolog exits after a query

`run_diagnosis/2` and `run_diagnosis_for_ui/2` intentionally call `halt/0`.

For interactive testing, use:

```prolog
clear_observations,
add_symptom_list([...]),
diagnose(Device, Results).
```

### 17.4 No strong fault matched

Possible reasons:

- Too few symptoms were selected.
- The selected combination does not sufficiently match a rule.
- A single symptom belongs to a rule with three or more required symptoms.
- The necessary rule is missing.
- A custom case contains a misspelled symptom atom.

Inspect raw scores:

```prolog
?- clear_observations,
   add_symptom_list([your_symptom]),
   score_fault(Device, Fault, Score, MatchCount, Total, Matched).
```

### 17.5 A new Prolog symptom does not appear in the GUI

The GUI uses the separate `SYMPTOMS` dictionary in `app.py`. Add the new atom
and label there as well.

### 17.6 A custom case does not appear

Check:

1. `custom_cases.pl` exists in the project folder.
2. The facts use valid Prolog syntax.
3. `fault_info/6` and `fault_symptoms/3` use the same fault atom and device.
4. Symptom atoms match those selected by the UI.
5. Restart or diagnose again so a fresh Prolog process loads the file.

Load manually to reveal syntax errors:

```powershell
swipl -q -s repair_expert.pl
```

### 17.7 Changes made with `assertz/1` disappear

`assertz/1` changes the current in-memory Prolog database. It does not edit the
source files. Save permanent facts in a `.pl` file.

### 17.8 Duplicate custom results appear

`list_to_set/2` removes exact duplicate result terms, but cases with the same
fault atom and different labels, advice, or rules are not exact duplicates.
Avoid appending the same custom fault repeatedly.

---

## 18. Current Limitations and Improvement Ideas

### 18.1 Symptom data is duplicated

Symptoms are defined in both:

- `repair_devices_symptoms.pl`
- `app.py`

Improvement: ask Prolog for the symptom list so the GUI has one source of
truth.

### 18.2 Custom-case validation is limited

The UI sanitizes atom-like fields but does not verify that:

- Every custom symptom exists for the selected device.
- The fault atom is unique.
- A fault or symptom atom does not begin with a digit. For example, `5g_fault`
  is not a valid unquoted Prolog atom.
- Label or advice text is safe for every Prolog string edge case.
- The advice does not contain the `|` delimiter used by UI output.

Improvement: validate against Prolog facts and use JSON for process output
instead of a custom pipe-separated format.

### 18.3 Custom file writes are append-only

Adding the same custom case repeatedly creates repeated facts.

Improvement: provide edit/delete operations and rewrite the custom file
through a structured persistence layer.

### 18.4 Runtime admin changes are not persistent

`add_custom_case/7` and `remove_case/1` modify only one Prolog process.

Improvement: add explicit save predicates or manage persistence in Python.

### 18.5 Device and symptom validity is not enforced by diagnosis

`run_diagnosis/2` does not call `device/1` or validate every symptom with
`symptom/3`.

Improvement: reject unsupported devices and unknown symptoms before scoring.

### 18.6 Scoring is heuristic

Every symptom within a fault rule has equal importance. The score is based on
completeness and evidence count, not probability or clinical certainty.

Improvement options:

- Add symptom weights.
- Add required versus optional symptoms.
- Add negative evidence.
- Add expert-defined fault priorities.
- Calibrate score labels such as weak, moderate, and strong.

### 18.7 Overlapping rules produce multiple diagnoses

This is expected because many faults share symptoms. The system ranks
candidates but does not prove that the first result is definitely correct.

Improvement: ask follow-up questions that best distinguish the top faults.

### 18.8 The GUI starts a new Prolog process for each diagnosis

This keeps each run isolated and automatically reloads custom facts, but it has
startup overhead.

Improvement: use a persistent Prolog service or a Python-Prolog integration
library when the project requires higher throughput.

### 18.9 The project folder button only displays a path

`open_folder_hint` shows the folder location but does not open the operating
system's file manager.

### 18.10 Repair results are guidance, not a guaranteed diagnosis

The system uses a small educational rule base. Real repair work may require:

- Electrical measurements
- Hardware inspection
- Vendor diagnostics
- Data-safety precautions
- A trained technician

---

## 19. Short Explanation for a Demonstration

> This project is a rule-based expert system for laptop and phone repair. The
> user selects a device and observed symptoms in a Python Tkinter interface.
> Python starts SWI-Prolog and sends the device and symptom atoms to
> `run_diagnosis_for_ui/2`. Prolog clears old observations, stores the new
> symptoms dynamically, and compares them with every `fault_symptoms/3` rule.
> It builds matched and missing symptom lists, calculates a score using match
> completeness and evidence count, and keeps faults with a score of at least
> 50. It joins those matches with `fault_info/6`, removes duplicate results,
> sorts them, and prints machine-readable rows. Python parses those rows and
> displays the fault, match, score, severity, cost, matched symptoms, and repair
> advice. The project demonstrates facts, rules, recursion, lists,
> backtracking, dynamic predicates, cuts, negation, collection predicates,
> sorting, formatted output, and Python-Prolog integration.

---

## 20. Glossary

| Term | Meaning in this project |
|---|---|
| Atom | Internal identifier such as `cooling_problem` |
| Arity | Number of predicate arguments, such as 6 in `fault_info/6` |
| Backtracking | Prolog searching for additional matching solutions |
| Clause | A fact or rule |
| Cut (`!`) | Commits to choices made before the cut in the current predicate |
| Dynamic predicate | Predicate whose clauses may change at runtime |
| Evidence | Selected symptoms that match a fault rule |
| Expert system | Program that reasons using encoded specialist knowledge |
| Fact | Unconditional statement such as `device(phone).` |
| Functor | Name of a compound term, such as `result` or `fault_info` |
| Goal | A query or body condition Prolog attempts to prove |
| Knowledge base | Collection of facts and rules |
| Multifile predicate | Predicate whose clauses may be defined in several files |
| Negation as failure | `\+ Goal`, meaning the goal cannot be proven |
| Predicate | Named relation, such as `diagnose/2` |
| Recursion | A predicate calling itself on a smaller problem |
| Rule | Conditional clause containing `:-` |
| Term | A Prolog value, including atoms, variables, lists, and structures |
| Working memory | Temporary `observed_symptom/1` facts for one diagnosis |

---

## Final Execution Summary

```text
User selects symptoms
  -> Python collects atom names
  -> Python builds a Prolog goal
  -> SWI-Prolog loads repair_expert.pl
  -> optional custom_cases.pl is consulted
  -> observations are cleared and inserted
  -> every fault rule is scored
  -> scores below 50 are rejected
  -> fault descriptions are joined
  -> results are deduplicated and sorted
  -> Prolog prints pipe-separated rows
  -> Python parses rows into dictionaries
  -> Tkinter displays ranked diagnoses and advice
```
