% =========================================================
% Module 7: Dynamic Knowledge Base Administration
% =========================================================
% These predicates show how new repair cases can be added or
% removed while Prolog is running.

add_custom_case(Device, Fault, Label, Symptoms, Severity, Cost, Advice) :-
    assertz(fault_info(Fault, Device, Label, Severity, Cost, Advice)),
    assertz(fault_symptoms(Device, Fault, Symptoms)).

remove_case(Fault) :-
    retractall(fault_info(Fault, _, _, _, _, _)),
    retractall(fault_symptoms(_, Fault, _)).

% Recursive list deletion: remove one occurrence of an item.
delete_from_list(Item, [Item|Tail], Tail).
delete_from_list(Item, [Head|Tail], [Head|Remaining]) :-
    delete_from_list(Item, Tail, Remaining).
