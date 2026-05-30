% =========================================================
% Module 7: Dynamic Knowledge Base Administration
% =========================================================
% These predicates allow the UI or Prolog console to add/remove
% repair cases while the program is running.

add_custom_case(Device, Fault, Label, Symptoms, Severity, Cost, Advice, BackupNeeded) :-
    assertz(fault_info(Fault, Device, Label, Severity, Cost, Advice, BackupNeeded)),
    assertz(fault_symptoms(Device, Fault, Symptoms)).

remove_case(Fault) :-
    retractall(fault_info(Fault, _, _, _, _, _, _)),
    retractall(fault_symptoms(_, Fault, _)).
