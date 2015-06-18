//added by step 1 (A1)
pool gold is "$"
user converter buyMedkit
pool hp at 100 is "+"
costMedkit: gold -10-> buyMedkit
getMedkit: buyMedkit -20-> hp
