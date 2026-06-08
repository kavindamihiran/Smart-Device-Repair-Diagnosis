% =========================================================
% Module 5: Diagnosis Engine
% =========================================================
% This module stores selected symptoms temporarily, compares them
% with the diagnostic rules, scores matches, and sorts results.

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

compare_score(Order, result(FaultA, ScoreA, _, _, _, _, _, MatchA, TotalA),
                    result(FaultB, ScoreB, _, _, _, _, _, MatchB, TotalB)) :-
    ( MatchA > MatchB -> Order = '<'
    ; MatchA < MatchB -> Order = '>'
    ; ScoreA > ScoreB -> Order = '<'
    ; ScoreA < ScoreB -> Order = '>'
    ; TotalA > TotalB -> Order = '<'
    ; TotalA < TotalB -> Order = '>'
    ; compare(Order, FaultA, FaultB)
    ).

make_result(Device,
            result(Fault, Score, Label, Severity, Cost, Advice, Matched, MatchCount, Total)) :-
    likely_fault(Device, Fault, Score, MatchCount, Total, Matched),
    fault_info(Fault, Device, Label, Severity, Cost, Advice).

diagnose(Device, ResultsSorted) :-
    findall(Result, make_result(Device, Result), Results),
    list_to_set(Results, Unique),
    predsort(compare_score, Unique, ResultsSorted).
