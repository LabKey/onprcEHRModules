WITH
    BaseAssignments AS (...),
    JoinedAssignments AS (...),
    Metrics AS (...),

    ResourceRules AS (...),
    ObeseRules AS (...),
    TMBRules AS (...),
    InfantRules AS (...),
    CreditSourceRules AS (...),
    ChargeIdRules AS (...),
    QuantityRules AS (...),

    FinalLeaseFees AS (...),
    FinalSetupFees AS (...),
    FinalAdjustments AS (...)

SELECT * FROM FinalLeaseFees
UNION ALL
SELECT * FROM FinalSetupFees
UNION ALL
SELECT * FROM FinalAdjustments
;
