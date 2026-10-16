extends GutTest
const E = preload("res://scripts/sim/economy.gd")
var c: Dictionary
func before_each() -> void:
 c=DataManager.config("economy").duplicate(true)
func test_quality_is_weighted_and_bounded() -> void:
 assert_almost_eq(E.quality(80,60,40,50,c),63.6,.001)
 assert_eq(E.quality(200,200,200,200,c),100.0)
func test_script_improves_with_time_and_writer() -> void:
 var stats := {"Script":40,"Vision":40}
 assert_gt(E.script_quality(stats,4,1,70),E.script_quality(stats,1,1,0))
func test_production_cost_known_example() -> void:
 assert_almost_eq(E.production_cost(6,3.5,.1,.9),20.79,.001)
 assert_eq(E.production_cost(-1,3,0,1),0.0)
func test_pitch_is_never_guaranteed() -> void:
 assert_lte(E.pitch_chance(100,100,1,100,.9),.94)
 assert_gte(E.pitch_chance(0,0,1000,1,.1),.08)
func test_holidays_and_clashes_affect_opening() -> void:
 var ordinary := E.opening_occupancy(60,40,60,1,0,c)
 assert_gt(E.opening_occupancy(60,40,60,1.8,0,c),ordinary)
 assert_lt(E.opening_occupancy(60,40,60,1,.5,c),ordinary)
func test_occupancy_capped() -> void:
 assert_lte(E.opening_occupancy(100,100,100,4,0,c),.95)
func test_weekly_gross_exact_capacity() -> void:
 c.seats=100;c.shows=1;c.ticket=100;c.occupancy_cap=1
 assert_almost_eq(E.weekly_gross(10,.5,1,50,0,c),3.5,.0001)
func test_no_screens_no_gross() -> void:
 assert_eq(E.weekly_gross(0,.9,1,90,0,c),0.0)
func test_piracy_reduces_gross() -> void:
 assert_lt(E.weekly_gross(50,.5,1,60,.5,c),E.weekly_gross(50,.5,1,60,0,c))
func test_bad_word_of_mouth_decays() -> void:
 assert_lt(E.weekly_gross(40,.5,3,25,0,c),E.weekly_gross(40,.5,1,25,0,c))
func test_great_word_of_mouth_can_grow() -> void:
 assert_gt(E.weekly_gross(40,.2,3,100,0,c),E.weekly_gross(40,.2,1,100,0,c))
func test_advance_recoupment() -> void:
 var result := E.producer_receipts(100,2,40,50,c)
 assert_almost_eq(result.income,10.85,.001)
 assert_almost_eq(result.advance_remaining,37.0,.001)
func test_star_opening_share() -> void:
 assert_gt(E.producer_receipts(100,1,90,0,c).income,E.producer_receipts(100,2,90,0,c).income)
func test_receipts_never_exceed_gross() -> void:
 for star in [0,50,100]:
  assert_lte(E.producer_receipts(100,1,star,0,c).income,100.0)
func test_rights_price() -> void:
 assert_eq(E.rights_price(60,40,20,c),60.0)
func test_profit_only_splits_positive_profit() -> void:
 assert_eq(E.director_profit(50,100,.2,8),8.0)
 assert_eq(E.director_profit(200,100,.2,8),28.0)
func test_interest_nonnegative() -> void:
 assert_eq(E.interest(100,.002),.2)
 assert_eq(E.interest(-1,.002),0.0)
func test_benchmarks_are_explicitly_synthetic() -> void:
 assert_eq(DataManager.rows("benchmark_films").size(),40)
 for row in DataManager.rows("benchmark_films"):
  assert_true(row.fictional)
func test_synthetic_benchmarks_span_flops_and_hits() -> void:
 var flop_count: int = 0
 var hit_count: int = 0
 for film in DataManager.rows("benchmark_films"):
  var producer: float = E.producer_receipts(film.gross,2,40,0,c).income
  if producer<film.budget: flop_count+=1
  else: hit_count+=1
 assert_gt(flop_count,hit_count,"Producer accounting leaves most synthetic releases below break-even")
 assert_gt(hit_count,0,"Calibration includes successful scenarios as well")
func test_low_quality_star_film_drops_despite_large_opening() -> void:
 var opening := E.opening_occupancy(95,80,25,1,0,c)
 var quiet_opening := E.opening_occupancy(30,20,80,1,0,c)
 assert_gt(opening,quiet_opening)
 assert_lt(E.weekly_gross(50,opening,6,25,.08,c),E.weekly_gross(50,quiet_opening,6,80,.08,c))
