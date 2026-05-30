% =========================================================
% Module 4: Repair Worthiness Advisor
% =========================================================
% Combines cost, severity, and data risk to recommend a practical action.

% repair_decision(Cost, Severity, Decision).

repair_decision(high, critical, consider_replacing).
repair_decision(high, high, replace_faulty_part).
repair_decision(high, medium, repair_device).
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
    ( BackupNeeded = yes
      -> Decision = backup_and_repair
      ;  Decision = BaseDecision
    ).
get_decision(_, _, _, repair_device).  % fallback

decision_label(replace_device, "Replace Device").
decision_label(consider_replacing, "Compare Repair vs Replace").
decision_label(replace_faulty_part, "Replace Faulty Part").
decision_label(backup_and_repair, "Backup Data & Repair").
decision_label(repair_device, "Repair Device").
