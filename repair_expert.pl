% =========================================================
% Smart Laptop & Phone Repair Diagnosis Expert System
% Course: CM2520 - Deductive Reasoning and Logic Programming
% File: repair_expert.pl
% Run with SWI-Prolog.
% =========================================================

:- dynamic observed_symptom/1.
:- dynamic fault_info/7.
:- dynamic fault_symptoms/3.
:- multifile fault_info/7.
:- multifile fault_symptoms/3.

% Optional custom repair cases saved from the Python UI.
:- initialization(load_custom_cases).
load_custom_cases :-
    exists_file('custom_cases.pl'), !,
    consult('custom_cases.pl').
load_custom_cases.

% -----------------------------
% Devices
% -----------------------------
device(laptop).
device(phone).

% -----------------------------
% Symptom dictionary
% symptom(Device, SymptomAtom, HumanReadableLabel).
% -----------------------------
symptom(laptop, no_power, "Does not power on").
symptom(laptop, no_charging, "Does not charge").
symptom(laptop, battery_drain, "Battery drains quickly").
symptom(laptop, random_shutdown, "Random shutdown").
symptom(laptop, overheating, "Overheating").
symptom(laptop, loud_fan, "Fan is very loud").
symptom(laptop, black_screen, "Black screen").
symptom(laptop, display_flicker, "Display flickering").
symptom(laptop, slow_performance, "Slow performance").
symptom(laptop, boot_failure, "Boot failure").
symptom(laptop, clicking_sound, "Clicking sound from storage").
symptom(laptop, keyboard_not_working, "Keyboard not working").
symptom(laptop, wifi_not_working, "Wi-Fi not working").
symptom(laptop, virus_popups, "Unwanted popups / suspicious apps").
symptom(laptop, blue_screen, "Blue screen / system crash").

symptom(phone, no_power, "Does not power on").
symptom(phone, no_charging, "Does not charge").
symptom(phone, battery_drain, "Battery drains quickly").
symptom(phone, random_shutdown, "Random shutdown").
symptom(phone, overheating, "Overheating").
symptom(phone, cracked_screen, "Cracked screen").
symptom(phone, black_screen, "Black screen").
symptom(phone, touch_not_working, "Touch not working").
symptom(phone, slow_performance, "Slow performance").
symptom(phone, storage_full, "Storage full").
symptom(phone, wifi_not_working, "Wi-Fi not working").
symptom(phone, camera_not_working, "Camera not working").
symptom(phone, speaker_not_working, "Speaker not working").
symptom(phone, water_damage, "Water damage").
symptom(phone, boot_loop, "Phone stuck in boot loop").

% -----------------------------
% Fault information

% Device: laptop | phone
% Severity: low | medium | high | critical
% Cost: low | medium | high
% BackupNeeded: yes | no

% fault_info(FaultAtom, Device, Label, Severity, Cost, Advice, BackupNeeded).
% -----------------------------
fault_info(battery_failure, laptop, "Battery Failure", high, medium,
    "Replace the battery. Also check adapter health and charging cycle count.", no).
fault_info(charger_or_port_issue, laptop, "Charger or Charging Port Issue", medium, low,
    "Test with another adapter. Clean or replace the charging port if needed.", no).
fault_info(cooling_problem, laptop, "Cooling System Problem", high, medium,
    "Clean the fan, replace thermal paste, and check air vents.", no).
fault_info(display_damage, laptop, "Display Cable or Panel Damage", high, high,
    "Check display cable first. If the panel is damaged, replace the screen.", no).
fault_info(storage_failure, laptop, "Hard Disk / SSD Failure", critical, high,
    "Stop using the device heavily. Backup data immediately and replace storage.", yes).
fault_info(malware_infection, laptop, "Malware or Unwanted Software", medium, low,
    "Run a trusted malware scan, remove suspicious apps, and update the OS.", yes).
fault_info(ram_or_os_crash, laptop, "RAM Issue or Operating System Crash", high, medium,
    "Run memory diagnostics. Re-seat RAM or repair/reinstall the OS.", yes).
fault_info(keyboard_fault, laptop, "Keyboard Hardware Fault", medium, medium,
    "Check keyboard connector. Replace keyboard if multiple keys fail.", no).
fault_info(wifi_adapter_fault, laptop, "Wi-Fi Adapter or Driver Fault", medium, low,
    "Reinstall network driver. If still failing, test or replace Wi-Fi adapter.", no).
fault_info(power_thermal_issue, laptop, "Power and Thermal Issue", high, medium,
    "Check battery health, fan operation, and heat buildup. Clean cooling parts before replacing hardware.", no).
fault_info(thermal_boot_instability, laptop, "Thermal Boot Instability", high, medium,
    "Clean the cooling system, check thermal paste, and run OS and memory diagnostics.", yes).
fault_info(storage_or_system_crash, laptop, "Storage or System Crash", critical, high,
    "Backup data immediately if possible. Test storage health and repair or reinstall the operating system.", yes).

fault_info(phone_battery_failure, phone, "Phone Battery Failure", high, medium,
    "Replace battery. Check charging IC if battery replacement does not solve it.", no).
fault_info(phone_charging_port_issue, phone, "Charging Port Issue", medium, low,
    "Clean charging port carefully. Replace port if cable does not fit firmly.", no).
fault_info(phone_display_damage, phone, "Display or Touch Panel Damage", high, high,
    "Replace display assembly if screen/touch is damaged.", no).
fault_info(phone_storage_overload, phone, "Storage Overload", medium, low,
    "Delete unnecessary files, clear app cache, and move media to cloud/PC.", yes).
fault_info(phone_water_damage, phone, "Water Damage", critical, high,
    "Power off immediately. Do not charge. Take to service center for board cleaning.", yes).
fault_info(phone_camera_fault, phone, "Camera Module Fault", medium, medium,
    "Check camera permission and app first. Replace camera module if hardware issue remains.", no).
fault_info(phone_speaker_fault, phone, "Speaker or Audio IC Fault", medium, medium,
    "Clean speaker grill. If sound is absent, test and replace speaker module.", no).
fault_info(phone_network_fault, phone, "Network / Wi-Fi Fault", medium, low,
    "Reset network settings, update software, and check antenna or Wi-Fi module.", no).
fault_info(phone_boot_loop_fault, phone, "Boot Loop / Firmware Issue", critical, medium,
    "Backup if possible, then repair firmware. Avoid factory reset before data backup.", yes).
fault_info(phone_power_thermal_issue, phone, "Phone Power and Thermal Issue", high, medium,
    "Check battery health, charging circuit, and overheating causes. Replace battery if swelling or fast drain is found.", no).
fault_info(phone_physical_display_power_issue, phone, "Physical Display and Power Issue", high, high,
    "Inspect display assembly and battery connection. Replace damaged screen parts after checking power delivery.", no).
fault_info(phone_liquid_display_issue, phone, "Liquid Display Damage", critical, high,
    "Power off immediately. Do not charge. Clean the board and inspect the display connector and panel.", yes).

% -----------------------------
% Diagnostic rules
% A fault is likely when enough required symptoms are observed.

% fault_symptoms(Device, FaultAtom, RequiredSymptoms).
% -----------------------------
fault_symptoms(laptop, battery_failure,
    [battery_drain, random_shutdown, no_power]).
fault_symptoms(laptop, charger_or_port_issue,
    [no_charging, no_power]).
fault_symptoms(laptop, cooling_problem,
    [overheating, loud_fan, random_shutdown, slow_performance]).
fault_symptoms(laptop, display_damage,
    [black_screen, display_flicker]).
fault_symptoms(laptop, storage_failure,
    [boot_failure, clicking_sound, slow_performance]).
fault_symptoms(laptop, malware_infection,
    [slow_performance, virus_popups]).
fault_symptoms(laptop, ram_or_os_crash,
    [blue_screen, random_shutdown, boot_failure]).
fault_symptoms(laptop, keyboard_fault,
    [keyboard_not_working]).
fault_symptoms(laptop, wifi_adapter_fault,
    [wifi_not_working]).
fault_symptoms(laptop, power_thermal_issue,
    [battery_drain, overheating, loud_fan, random_shutdown]).
fault_symptoms(laptop, thermal_boot_instability,
    [overheating, loud_fan, boot_failure, blue_screen]).
fault_symptoms(laptop, storage_or_system_crash,
    [clicking_sound, random_shutdown, blue_screen, boot_failure]).

fault_symptoms(phone, phone_battery_failure,
    [battery_drain, random_shutdown, no_power]).
fault_symptoms(phone, phone_charging_port_issue,
    [no_charging, no_power]).
fault_symptoms(phone, phone_display_damage,
    [cracked_screen, black_screen, touch_not_working]).
fault_symptoms(phone, phone_storage_overload,
    [storage_full, slow_performance]).
fault_symptoms(phone, phone_water_damage,
    [water_damage, no_power, no_charging]).
fault_symptoms(phone, phone_camera_fault,
    [camera_not_working]).
fault_symptoms(phone, phone_speaker_fault,
    [speaker_not_working]).
fault_symptoms(phone, phone_network_fault,
    [wifi_not_working]).
fault_symptoms(phone, phone_boot_loop_fault,
    [boot_loop, random_shutdown]).
fault_symptoms(phone, phone_power_thermal_issue,
    [battery_drain, overheating, random_shutdown, no_power]).
fault_symptoms(phone, phone_physical_display_power_issue,
    [battery_drain, cracked_screen, black_screen, touch_not_working]).
fault_symptoms(phone, phone_liquid_display_issue,
    [water_damage, cracked_screen, black_screen, touch_not_working]).

% -----------------------------
% Repair Worthiness Advisor
% Combines cost and severity to recommend: repair, replace, or backup_and_repair.

% repair_decision(Cost, Severity, Decision).
% -----------------------------
repair_decision(high, critical, replace_device).
repair_decision(high, high, consider_replacing).
repair_decision(high, medium, backup_and_repair).
repair_decision(high, low, repair_device).

repair_decision(medium, critical, backup_and_repair).
repair_decision(medium, high, repair_device).
repair_decision(medium, medium, repair_device).
repair_decision(medium, low, repair_device).

repair_decision(low, critical, backup_and_repair).
repair_decision(low, high, repair_device).
repair_decision(low, medium, repair_device).
repair_decision(low, low, repair_device).

% Get a human-readable decision label for a fault.
get_decision(Cost, Severity, BackupNeeded, Decision) :-
    repair_decision(Cost, Severity, BaseDecision),
    ( BackupNeeded = yes, BaseDecision = repair_device
      -> Decision = backup_and_repair
      ;  Decision = BaseDecision
    ).
get_decision(_, _, _, repair_device).  % fallback

decision_label(replace_device, "Replace Device").
decision_label(consider_replacing, "Consider Replacing").
decision_label(backup_and_repair, "Backup Data & Repair").
decision_label(repair_device, "Repair Device").

% -----------------------------
% Dynamic observed symptoms
% -----------------------------
clear_observations :- retractall(observed_symptom(_)).

add_observed_symptom(Symptom) :-
    \+ observed_symptom(Symptom),
    assertz(observed_symptom(Symptom)).
add_observed_symptom(_).

add_symptom_list([]).
add_symptom_list([H|T]) :-
    add_observed_symptom(H),
    add_symptom_list(T).

% -----------------------------
% Matching and scoring logic
% -----------------------------
matched_symptoms(Required, Matched) :-
    findall(S, (member(S, Required), observed_symptom(S)), Matched).

score_fault(Device, Fault, Score, MatchCount, Total, Matched) :-
    fault_symptoms(Device, Fault, Required),
    matched_symptoms(Required, Matched),
    length(Matched, MatchCount),
    length(Required, Total),
    Total > 0,
    MatchCount > 0,
    Score is (MatchCount * 100) // Total.

likely_fault(Device, Fault, Score, MatchCount, Total, Matched) :-
    score_fault(Device, Fault, Score, MatchCount, Total, Matched),
    Score >= 50.

% Sort by score descending. predsort comparator receives full result rows.
compare_score(Order, result(_, ScoreA, _, _, _, _, _, _, _, _),
                    result(_, ScoreB, _, _, _, _, _, _, _, _)) :-
    ( ScoreA > ScoreB -> Order = '<'
    ; ScoreA < ScoreB -> Order = '>'
    ; Order = '<'
    ).

make_result(Device,
            result(Fault, Score, Label, Severity, Cost, BackupNeeded, Advice, Matched, MatchCount, Total)) :-
    likely_fault(Device, Fault, Score, MatchCount, Total, Matched),
    fault_info(Fault, Device, Label, Severity, Cost, Advice, BackupNeeded).

diagnose(Device, ResultsSorted) :-
    findall(Result, make_result(Device, Result), Results),
    list_to_set(Results, Unique),
    predsort(compare_score, Unique, ResultsSorted).

% -----------------------------
% Console and UI output
% -----------------------------
run_diagnosis(Device, Symptoms) :-
    clear_observations,
    add_symptom_list(Symptoms),
    diagnose(Device, Results),
    print_results(Results),
    halt.

print_results([]) :-
    format('NO_RESULT|No strong fault matched|Try selecting more symptoms|~n').
print_results(Results) :-
    forall(member(R, Results), print_result_line(R)).

print_result_line(result(Fault, Score, Label, Severity, Cost, BackupNeeded, Advice, Matched, MatchCount, Total)) :-
    atomic_list_concat(Matched, ',', MatchedText),
    get_decision(Cost, Severity, BackupNeeded, Decision),
    decision_label(Decision, DecisionLabel),
    format('RESULT|~w|~d|~d|~d|~w|~w|~w|~w|~s|~s|~s|~n',
           [Fault, Score, MatchCount, Total, Severity, Cost, BackupNeeded, Label, Advice, MatchedText, DecisionLabel]).

% Backtracking demonstration: prints all known faults one by one.
list_all_faults :-
    fault_info(Fault, Device, Label, Severity, Cost, _Advice, BackupNeeded),
    format('~w | ~w | ~s | severity=~w | cost=~w | backup=~w~n',
           [Device, Fault, Label, Severity, Cost, BackupNeeded]),
    fail.
list_all_faults.

% -----------------------------
% Dynamic knowledge base administration
% -----------------------------
add_custom_case(Device, Fault, Label, Symptoms, Severity, Cost, Advice, BackupNeeded) :-
    assertz(fault_info(Fault, Device, Label, Severity, Cost, Advice, BackupNeeded)),
    assertz(fault_symptoms(Device, Fault, Symptoms)).

remove_case(Fault) :-
    retractall(fault_info(Fault, _, _, _, _, _, _)),
    retractall(fault_symptoms(_, Fault, _)).

% Example manual queries in SWI-Prolog:
% ?- [repair_expert].
% ?- clear_observations, add_symptom_list([overheating,loud_fan,random_shutdown]),
%    diagnose(laptop, Results).
% ?- run_diagnosis(phone, [battery_drain,random_shutdown,no_power]).
% ?- list_all_faults.
