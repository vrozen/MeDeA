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

//added by step 3 (A3)
pool bonus at 2 is "+"
user converter upgrade
costUpgrade: gold -10*bonus*bonus->upgrade
getUpgrade: upgrade-1->bonus

//added by step 4 (D1)
auto source kill
income: kill -bonus-> gold

//added by step 5 (F1)
auto drain damage
dmgHp: hp -(100-shield)*0.1-> damage

//added by step 6 (F2)
dmgShield: shield -5->damage
