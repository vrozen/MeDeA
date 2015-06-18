getHp: buyMedkit -20-> hp
pool gold is "$"
pool hp is "+"
costMedkit: gold -10-> buyMedkit
user converter buyMedkit
source kill
getHp: buyMedkit -20-> hp
costAct: gold -bonus * bonus * 10-> upgrade
pool hp is "+"
costMedkit: gold -10-> buyMedkit
user converter upgrade
user converter buyMedkit
pool bonus is "+"
getBonus: upgrade -1-> bonus
pool gold is "$"
income: kill -bonus-> gold
getHp: buyMedkit -20-> hp
pool gold is "$"
pool hp is "+"
costMedkit: gold -10-> buyMedkit
user converter buyMedkit
source kill
getHp: buyMedkit -20-> hp
pool hp is "+"
costMedkit: gold -10-> buyMedkit
user converter upgrade
user converter buyMedkit
pool bonus is "+"
getBonus: upgrade -1-> bonus
auto drain hit
pool gold is "$"
income: kill -bonus-> gold
costAct: gold -bonus * bonus * 10-> upgrade
damage: hp -10-> hit
getHp: buyMedkit -20-> hp
pool gold is "$"
pool hp is "+"
costMedkit: gold -10-> buyMedkit
user converter buyMedkit
source kill
getHp: buyMedkit -20-> hp
costAct: gold -bonus * bonus * 10-> upgrade
pool hp is "+"
costMedkit: gold -10-> buyMedkit
user converter upgrade
user converter buyMedkit
pool bonus is "+"
getBonus: upgrade -1-> bonus
pool gold is "$"
income: kill -bonus-> gold
getHp: buyMedkit -20-> hp
pool gold is "$"
pool hp is "+"
costMedkit: gold -10-> buyMedkit
user converter buyMedkit
