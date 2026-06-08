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

print_result_line(result(Fault, Score, Label, Severity, Cost, Advice, Matched, MatchCount, Total)) :-
    atomic_list_concat(Matched, ',', MatchedText),
    format('RESULT|~w|~d|~d|~d|~w|~w|~w|~s|~s~n',
           [Fault, Score, MatchCount, Total, Severity, Cost, Label, Advice, MatchedText]).

% backtracking demonstration: prints all known faults one by one.
list_all_faults :-
    fault_info(Fault, Device, Label, Severity, Cost, _Advice),
    format('~w | ~w | ~s | severity=~w | cost=~w~n',
           [Device, Fault, Label, Severity, Cost]),
    fail.
list_all_faults.
