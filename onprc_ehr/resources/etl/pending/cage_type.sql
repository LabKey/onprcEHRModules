Select
	CageTypeID,
	CageSize,
	CageDescription,
	CageSlots,
	CageCapacity,
	MaxAnimalSize,
	DateCreated as created
From  Ref_CageTypes
where DateDisabled is null
