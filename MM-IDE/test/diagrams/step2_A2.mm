//added by step 1 (A1)
pool gold is "$"
user converter buyMedkit
pool hp at 100 is "+"
costMedkit: gold -10-> buyMedkit
getMedkit: buyMedkit -20-> hp

//added by step 2 (A2)
pool shield is "+"
user converter buyShield
costShield: gold -10+shield-> buyShield
getShield: buyShield -10-> shield
