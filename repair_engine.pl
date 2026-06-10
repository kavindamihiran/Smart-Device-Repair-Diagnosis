% =======================================================
% Module 5: Diagnosis Engine
% =========================================================
% This module stores selected symptoms temporarily, compares them
% with the diagnostic rules, scores matches, and sorts results.



% --------------------------------------------------------------------------------
% Dynamic observed symptoms
% -------------------------------------------------------------------------------

clear_observations :-
    retractall(observed_symptom(_)).

% The cut makes duplicate insertion deterministic: once an observation
% already exists, Prolog must not backtrack into the assertz/1 clause.

add_observed_symptom(Symptom) :-
    observed_symptom(Symptom),
    !.
add_observed_symptom(Symptom) :-
    assertz(observed_symptom(Symptom)).

add_symptom_list([]).
add_symptom_list([H|T]) :-
    add_observed_symptom(H),
    add_symptom_list(T).

% ex: The runtime knowledge base becomes:
% observed_symptom(overheating).
% observed_symptom(loud_fan).
% observed_symptom(random_shutdown).

% ----------------------------------------------------------------------------------
% Recursive list predicates
% ---------------------------------------------------------------------------------
% These are versions of member/2, append/3, and length/2.

repair_member(Item, [Item|_]).
repair_member(Item, [_|Tail]) :-
    repair_member(Item, Tail).

repair_append([], List, List).
repair_append([Head|Tail], List, [Head|CombinedTail]) :-
    repair_append(Tail, List, CombinedTail).

repair_length([], 0).
repair_length([_|Tail], Length) :-
    repair_length(Tail, TailLength),
    Length is TailLength + 1.



% --------------------------------------------------------------------------------------
% Matching and scoring logic
% --------------------------------------------------------------------------------------

matched_symptoms(Required, Matched) :-
    findall(
        Symptom,
        (
            repair_member(Symptom, Required),
            observed_symptom(Symptom)
        ),
        Matched
    ).

% add_symptom_list([overheating, random_shutdown]).

% ?- matched_symptoms(
%        [overheating, loud_fan, random_shutdown, slow_performance],
%        Matched
%    ).

% overheating       required and observed -> collect
% loud_fan          required but not observed -> ignore
% random_shutdown   required and observed -> collect
% slow_performance  required but not observed -> ignore

% Matched = [overheating, random_shutdown].

missing_symptoms(Required, Missing) :-
    findall(
        Symptom,
        (
            repair_member(Symptom, Required),
            \+ observed_symptom(Symptom)
        ),
        Missing
    ).

% overheating       observed -> ignore
% loud_fan          not observed -> collect
% random_shutdown   observed -> ignore
% slow_performance  not observed -> collect

% Missing = [loud_fan, slow_performance].


score_fault(Device, Fault, Score, MatchCount, Total, Matched) :-
    fault_symptoms(Device, Fault, Required),
    matched_symptoms(Required, Matched),
    missing_symptoms(Required, Missing),
    repair_append(Matched, Missing, ClassifiedSymptoms),
    repair_length(Matched, MatchCount),
    repair_length(ClassifiedSymptoms, Total),
    Total > 0,
    MatchCount > 0,
    
    % Score uses both completeness and evidence amount, so 2/3 is stronger than 1/1.
    MatchPercent is (MatchCount * 100) // Total,
    EvidenceWeight is min(MatchCount * 50, 100),
    Score is (MatchPercent + EvidenceWeight) // 2.

likely_fault(Device, Fault, Score, MatchCount, Total, Matched) :-
    score_fault(Device, Fault, Score, MatchCount, Total, Matched),
    Score >= 50.



make_result(Device,
            result(Fault, Score, Label, Severity, Cost, Advice, Matched, MatchCount, Total)) :-
    
    likely_fault(Device, Fault, Score, MatchCount, Total, Matched),
    fault_info(Fault, Device, Label, Severity, Cost, Advice).

diagnose(Device, ResultsSorted) :-
    findall(Result, make_result(Device, Result), Results),
    list_to_set(Results, Unique),
    predsort(compare_score, Unique, ResultsSorted). % usng compare_score logic sort Unique list and store result in ResultsSroted

compare_score(Order, result(FaultA, ScoreA, _, _, _, _, _, MatchA, TotalA),
                    result(FaultB, ScoreB, _, _, _, _, _, MatchB, TotalB)) :-
    ( MatchA > MatchB -> Order = '<'
    ; MatchA < MatchB -> Order = '>'
    ; ScoreA > ScoreB -> Order = '<'
    ; ScoreA < ScoreB -> Order = '>'
    ; TotalA > TotalB -> Order = '<'
    ; TotalA < TotalB -> Order = '>'
    ; compare(Order, FaultA, FaultB) % alphabetical order
    ).

% The comparison priority is:

% Higher match count
% Higher score
% Higher total symptom count
% Alphabetical fault atom






% full workflow

% run_diagnosis/2
%     -> clear_observations/0
%     -> add_symptom_list/1
%         -> add_observed_symptom/1
%     -> diagnose/2
%         -> findall/3
%             -> make_result/2
%                 -> likely_fault/6
%                     -> score_fault/6
%                         -> fault_symptoms/3
%                         -> matched_symptoms/2
%                         -> missing_symptoms/2
%                         -> score calculation
%                 -> fault_info/6
%         -> list_to_set/2
%         -> predsort/3
%             -> compare_score/3
%     -> print_terminal_results/1
%     -> halt/0