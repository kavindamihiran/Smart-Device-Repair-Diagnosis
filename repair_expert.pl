% =========================================================
% Smart Laptop & Phone Repair Diagnosis Expert System
% Course: CM2520 - Deductive Reasoning and Logic Programming
% File: repair_expert.pl
% Run with SWI-Prolog.
% =========================================================

% This is the main file. It loads the smaller files that make up
% the expert system, so app.py and terminal commands can still use:
%   swipl -q -s repair_expert.pl -g "run_diagnosis(laptop, [...])"

% Dynamic predicates can change while the program is running.
:- dynamic observed_symptom/1.

% Load each part of the expert system.
:- ensure_loaded('repair_devices_symptoms.pl').
:- ensure_loaded('repair_faults.pl').
:- ensure_loaded('repair_rules.pl').
:- ensure_loaded('repair_engine.pl').
:- ensure_loaded('repair_io.pl').

% Example manual queries in SWI-Prolog:
% ?- [repair_expert].
% ?- clear_observations, add_symptom_list([overheating,loud_fan,random_shutdown]),
%    diagnose(laptop, Results).
% ?- run_diagnosis(phone, [battery_drain,random_shutdown,no_power]).
% ?- list_all_faults.
