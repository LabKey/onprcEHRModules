SELECT
    e.protocol,
    p.protocol as Prime

from onprc_ehr.eIACUCtoProtocolPhase2 e join ehr.protocol p on e.protocol = p.protocol