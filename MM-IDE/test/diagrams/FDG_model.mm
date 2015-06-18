source kill
income: kill -bonus->gold
getHP: buyMedkit -20-> hp
pool gold is "$"
pool hp is "+"
costMedkit: gold -10-> buyMedkit
user converter upgrade
user converter buyMedkit
pool bonus is "+"
costUpgrade: gold -bonus*bonus*10-> upgrade
auto drain hit
getUpgrade: upgrade -1-> bonus
damage: hp -10-> hit