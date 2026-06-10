% =========================================================
% Smart Laptop & Phone Repair Diagnosis Expert System
% Course: CM2520 - Deductive Reasoning and Logic Programming
% File: repair_expert.pl
% Run with SWI-Prolog.
% =========================================================

% This is the main file. It loads the smaller files that make up
% the expert system, so app.py and terminal commands can still use:
%   swipl -q -s repair_expert.pl -g "run_diagnosis(laptop, [...])"
% The Python UI uses run_diagnosis_for_ui/2 for machine-readable output.

% Dynamic predicates can change while the program is running.

:- dynamic observed_symptom/1.
:- dynamic fault_info/6.
:- dynamic fault_symptoms/3.

% Multifile predicates can have facts spread across several files.

:- multifile fault_info/6.
:- multifile fault_symptoms/3.

% Load each part of the expert system.

:- ensure_loaded('repair_devices_symptoms.pl').
:- ensure_loaded('repair_faults.pl').
:- ensure_loaded('repair_rules.pl').
:- ensure_loaded('repair_engine.pl').
:- ensure_loaded('repair_io.pl').
:- ensure_loaded('repair_admin.pl').

% Optional custom repair cases saved from the Python UI.

:- initialization(load_custom_cases).

load_custom_cases :-
    exists_file('custom_cases.pl'), !,
    consult('custom_cases.pl').
load_custom_cases.


% ----------------------------------------------------------------------------------------
% help
% ----------------------------------------------------------------------------------------

%  load and run a diagnosis
% ?- [repair_expert].
% ?- run_diagnosis(laptop, [overheating, loud_fan, slow_performance]).
% ?- run_diagnosis(phone, [battery_drain, random_shutdown, no_power]).

%
% Inspect knowledge facts and rules:
% ?- device(Device).
% ?- symptom(laptop, Symptom, Label).
% ?- fault_info(battery_failure, Device, Label, Severity, Cost, Advice).
% ?- fault_symptoms(laptop, cooling_problem, RequiredSymptoms).
%

%  inspect the complete sorted diagnosis result
% ?- clear_observations, add_symptom_list([overheating, loud_fan, slow_performance]), diagnose(laptop, Results).
%
% Test one exact fault and see its score
% ?- clear_observations,
%    add_symptom_list([overheating, loud_fan, slow_performance]),
%    score_fault(laptop, cooling_problem, Score, MatchCount, Total, Matched).
%
% Inspect working memory and evidence:
% ?- clear_observations,
%    add_symptom_list([overheating, loud_fan, slow_performance]),
%    findall(S, observed_symptom(S), Observed).

% ?- fault_symptoms(laptop, cooling_problem, Required),
%    matched_symptoms(Required, Matched),
%    missing_symptoms(Required, Missing).
%
%  custom recursive list predicates
% ?- repair_member(overheating, [no_power, overheating, loud_fan]).
% ?- repair_append([overheating], [loud_fan], Combined).
% ?- repair_append(Left, Right, [overheating, loud_fan]).
% ?- repair_length([overheating, loud_fan, no_power], Length).
% ?- delete_from_list(loud_fan, [overheating, loud_fan, no_power], Remaining).
%
% Other examples: reporting and backtracking
% ?- list_all_faults.
% ?- faults_by_severity(laptop, Severity, Faults).
% ?- sorted_faults(phone, Faults).
%
% Other examples: temporary dynamic knowledge-base changes
% ?- add_custom_case(laptop, demo_fault, "Demo Fault",
%    [no_power, overheating], low, low, "Demo advice").
% ?- remove_case(demo_fault).
