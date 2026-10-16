class_name FilmEconomy
extends RefCounted
## All money is lakh BDT. Gross is public ticket sales; receipts are producer income.
static func script_quality(stats: Dictionary, weeks: int, fit: float, writer: float) -> float:
 return clampf(float(stats.get("Script", 40))*.45 + float(stats.get("Vision",40))*.25 + minf(weeks*4.0,20.0) + writer*.15 + fit*5.0, 5, 100)
static func quality(script: float, direction: float, cast: float, crew: float, config: Dictionary) -> float:
 return clampf(script*config.script_quality + direction*config.direction_quality + cast*config.cast_quality + crew*config.crew_quality, 1,100)
static func production_cost(days: float, daily: float, risk: float, trait_factor: float) -> float:
 return maxf(0,days)*maxf(0,daily)*(1+clampf(risk,0,1))*maxf(0,trait_factor)
static func pitch_chance(business: float, reputation: float, budget: float, capacity: float, base: float) -> float:
 return clampf(base + business*.003 + reputation*.002 - maxf(0,budget-capacity)/maxf(capacity,1)*.4,.08,.94)
static func opening_occupancy(cast: float, hype: float, quality_score: float, holiday: float, competition: float, config: Dictionary) -> float:
 return clampf((config.occupancy_base+cast*config.occupancy_cast+hype*config.occupancy_hype+(quality_score-config.quality_center)*config.occupancy_quality)*holiday/(1+maxf(competition,0)),.015,config.occupancy_cap)
static func weekly_gross(screens: int, occupancy: float, week: int, quality_score: float, piracy: float, config: Dictionary) -> float:
 var retention: float = clampf(config.decay+(quality_score-config.quality_center)/50.0*config.wom_growth,.25,1.15)
 return maxf(0,screens)*config.seats*config.shows*7*config.ticket/100000.0*clampf(occupancy*pow(retention,maxi(0,week-1))*(1-clampf(piracy,0,1)),0,config.occupancy_cap)
static func producer_receipts(gross: float, week: int, star: float, advance_remaining: float, config: Dictionary) -> Dictionary:
 var multiplex_share: float = config.big_opening_share if week==1 and star>=80 else config.multiplex_share
 var single: float = gross*(1-config.multiplex_fraction)*config.single_share
 var recoup: float = minf(maxf(advance_remaining,0),single)
 return {"income": gross*config.multiplex_fraction*multiplex_share+single-recoup,"advance_remaining":maxf(0,advance_remaining-recoup)}
static func rights_price(quality_score: float, hype: float, base: float, config: Dictionary) -> float:
 return maxf(0,base+quality_score*config.rights_quality+hype*config.rights_hype)
static func director_profit(receipts: float, budget: float, backend: float, fee: float) -> float:
 return fee+maxf(0,receipts-budget)*clampf(backend,0,1)
static func interest(debt: float, rate: float) -> float:
 return maxf(0,debt)*maxf(0,rate)
