/*
 * Copyright (c) 2013-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
-- @SkipOnEmptySchemasBegin
DELETE FROM hormoneassay.assay_tests WHERE test = 'Progesterone';
INSERT INTO hormoneassay.assay_tests (test, code, units) VALUES ('Progesterone', 'P4', 'ng/ml');
-- @SkipOnEmptySchemasEnd
