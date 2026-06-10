% =========================================================
% Module 6: Console and Python UI Output
% =========================================================
% run_diagnosis/2 is the readable terminal entry point.
% run_diagnosis_for_ui/2 uses | separators so app.py can parse each result row.

run_diagnosis(Device, Symptoms) :-
    clear_observations,
    add_symptom_list(Symptoms),
    diagnose(Device, Results),
    print_terminal_results(Results).
    %halt.

run_diagnosis_for_ui(Device, Symptoms) :-
    clear_observations,
    add_symptom_list(Symptoms),
    diagnose(Device, Results),
    print_ui_results(Results),
    halt.

print_terminal_results([]) :-
    format('No strong fault matched.~n'),
    format('Advice: Try selecting more symptoms.~n').
print_terminal_results(Results) :-
    forall(member(R, Results), print_terminal_result_line(R)).

print_terminal_result_line(result(Fault, Score, Label, Severity, Cost, Advice, Matched, MatchCount, Total)) :-
    atomic_list_concat(Matched, ', ', MatchedText),
    format('----------------------------------------~n'),
    format('Fault Atom       : ~w~n', [Fault]),
    format('Fault Name       : ~s~n', [Label]),
    format('Score            : ~d percent~n', [Score]),
    format('Match Count      : ~d~n', [MatchCount]),
    format('Total Symptoms   : ~d~n', [Total]),
    format('Severity         : ~w~n', [Severity]),
    format('Estimated Cost   : ~w~n', [Cost]),
    format('Matched Symptoms : ~w~n', [MatchedText]),
    format('Repair Advice    : ~s~n', [Advice]).

print_ui_results([]) :-
    format('NO_RESULT|No strong fault matched|Try selecting more symptoms|~n').
print_ui_results(Results) :-
    forall(member(R, Results), print_ui_result_line(R)).

print_ui_result_line(result(Fault, Score, Label, Severity, Cost, Advice, Matched, MatchCount, Total)) :-
    atomic_list_concat(Matched, ',', MatchedText),
    format('RESULT|~w|~d|~d|~d|~w|~w|~w|~s|~s~n',
           [Fault, Score, MatchCount, Total, Severity, Cost, Label, Advice, MatchedText]).

% call/1 and fail force Prolog to print every solution by backtracking.
list_all_faults :-
    call(fault_info(Fault, Device, Label, Severity, Cost, _)),
    format('~w | ~w | ~s | severity=~w | cost=~w~n',
           [Device, Fault, Label, Severity, Cost]),
    fail.
list_all_faults.

% bagof/3 groups faults when Severity is left as a variable.
faults_by_severity(Device, Severity, Faults) :-
    bagof(
        Fault,
        Label^Cost^Advice^fault_info(
            Fault, Device, Label, Severity, Cost, Advice
        ),
        Faults
    ).


% setof/3 returns sorted fault atoms without duplicates.
sorted_faults(Device, Faults) :-
    setof(
        Fault,
        Label^Severity^Cost^Advice^fault_info(
            Fault, Device, Label, Severity, Cost, Advice
        ),
        Faults
    ).

% ex: sorted_faults(Device, Faults), write(Faults), nl,nl,nl, fail.