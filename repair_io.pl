% =========================================================
% Module 6: Console and Python UI Output
% =========================================================
% run_diagnosis/2 is the main terminal and Python entry point.
% Output uses | separators so app.py can parse each result row.

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
