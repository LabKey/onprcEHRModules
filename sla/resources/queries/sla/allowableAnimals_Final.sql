Select protocol, species, gender, allowed, GROUP_CONCAT(Breeding_Info, chr(10)) as Breeding_Info
From allowableAnimals_BreedingGroups
Group by protocol, species, gender, allowed
