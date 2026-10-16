"""Rebuild fictional seed data, never claiming measured historical budgets."""
import json, pathlib, random
ROOT=pathlib.Path(__file__).resolve().parents[1]/'data'
r=random.Random(342)
def save(name, rows):
 (ROOT/(name+'.json')).write_text(json.dumps(rows,ensure_ascii=False,indent=2)+'\n')
first=['Arian','Nabil','Farhan','Rafi','Imran','Tariq','Hasan','Adnan','Samir','Rohan','Mira','Nadia','Farah','Tisha','Raisa','Asha','Nila','Sadia','Rumi','Anika']
last=['Rahman','Chowdhury','Ahmed','Karim','Haque','Islam','Kabir','Sen','Das','Khan','Alam','Sarker','Bose','Akter','Begum']
genres=['Drama','Action','Romance','Thriller','Comedy','Family','Historical','Horror']
districts=['Dhaka','Chattogram','Sylhet','Rajshahi','Khulna','Barishal','Rangpur','Mymensingh','Cumilla','Cox’s Bazar','Tangail','Kushtia']
def people(n,role,offset=0):
 return [dict(id=f'{role}_{i}',name=f'{first[(i+offset)%20]} {last[(i//20+i*3+offset)%15]}',fictional=True,profession=role,age=12 if i==0 else 20+i%39,tier=1+i%5,genres=[genres[i%8]],fee_range=[2+(i%5)*8,6+(i%5)*15],reputation=30+i%60,availability=0.65+(i%4)*.1,quirks=['Early riser','Improviser','Method performer'][i%3],skill=40+i%55) for i in range(n)]
save('actors',people(35,'actor'));save('actresses',people(35,'actress',10));save('new_talent',people(15,'debut',5))
roles=['Writer','DOP','Editor','Art director','Composer','Singer','Lyricist','Costume','Makeup','VFX','Sound','Stunts']
crew=people(72,'crew',3)
for i,p in enumerate(crew):p['profession']=roles[i%12];p['fee_range']=[1+i%7,8+i%12]
save('crew',crew)
for category,role,n in [('producers','producer',16),('investors','investor',12),('production_houses','studio',12),('distributors','distributor',10),('marketing_agencies','agency',10),('journalists','journalist',10),('critics','critic',10),('music_labels','label',8)]:
 rows=people(n,role,7)
 for i,p in enumerate(rows):p.update(budget_range=[50,200+i*90],control=30+i*4,loyalty=30+i*3,red_flag=['None','Slow decisions','Strict delivery'][i%3],personality=['Pragmatic','Art patron','Commercial'][i%3])
 if category=='music_labels':
  for i,p in enumerate(rows):p.update(price_range=[3,20+i*2],window=0)
 save(category,rows)
save('cinema_halls',[dict(id=f'hall_{i}',name=f'{districts[i%12]} {"Cineplex" if i%4==0 else "Picture House"} {i//12+1}',district=districts[i%12],multiplex=i%4==0,seats=120+i%7*45,ticket=350 if i%4==0 else 150,producer_share=.31 if i%4==0 else .20,advance=2.0) for i in range(36)])
save('overseas_markets',[dict(id=f'market_{i}',name=n,price_range=[3+i,10+i*3],window=2) for i,n in enumerate(['UK','USA / Canada','Middle East','Malaysia / Singapore','Australia','West Bengal'])])
save('ott_platforms',[dict(id=f'ott_{i}',name=n,price_range=[20+i*10,120+i*30],window=8) for i,n in enumerate(['Chorki','Hoichoi','Bongo','Bioscope','Deepto Play'])])
save('tv_channels',[dict(id=f'tv_{i}',name=n,price_range=[5,20+i*5],window=16) for i,n in enumerate(['Channel i','NTV','ATN Bangla','RTV','Banglavision'])])
save('festivals_and_awards',[dict(id=f'award_{i}',name=n,threshold=62+i*4,campaign_cost=3+i,prestige=4+i) for i,n in enumerate(['National Film Awards','Meril-Prothom Alo','Dhaka International Film Festival','Busan festival selection','Oscar submission'])])
save('locations',[dict(id=f'loc_{i}',name=n,cost=1+i%4,permit=i%3+1,risk=.05+i*.01) for i,n in enumerate(['Old Dhaka lanes','Sadarghat','Padma village','FDC sets','Cox’s Bazar beach','Sylhet tea gardens','Sundarbans edge','Mumbai Film City','Rajshahi riverside','Chattogram port','Kushtia courtyard','Dhaka rooftop'])])
save('holidays',[dict(id=f'holiday_{i}',name=n,week=w,multiplier=m,note='Approximate planning window; lunar dates vary by year.') for i,(n,w,m) in enumerate([('Valentine’s Day',7,1.2),('Eid-ul-Fitr',12,1.8),('Pohela Boishakh',16,1.3),('Eid-ul-Adha',22,1.65),('Durga Puja',42,1.3),('Victory Day',50,1.25)])])
save('censor_rules',[dict(id='general',name='General audience',rating='U',delay=0,quality_loss=0),dict(id='teen',name='Mature themes: review and edits',rating='12+',delay=1,quality_loss=2),dict(id='adult',name='Restricted release',rating='18+',delay=2,quality_loss=4)])
save('benchmark_films',[dict(id=f'bench_{i}',name=f'Fictional calibration {i+1:02d}',fictional=True,budget=60+i*18,gross=round((60+i*18)*(.35+(i%10)*.65),1),release_window='Eid' if i%4==0 else 'Regular',note='Synthetic balancing scenario, not a historical film or verified financial report.') for i in range(40)])
backgrounds=['TV natok director','Assistant director','Film-school graduate','Ad-film maker','Content creator','Diaspora filmmaker','Writer-turned-director','Journalist']
stats=['Vision','Script','Direction','Leadership','Business','Network','Charm','Stamina','Marketing']
save('backgrounds',[dict(id=f'bg_{i}',name=n,cash=80+i*12,debt=20 if i==5 else 0,bonus_stat=stats[i],bonus=10,contacts=2+i%4,problem=['A stalled television contract','An overdue equipment invoice','No commercial credits','A demanding former client','An audience expecting free content','Few local contacts','An unfinished manuscript','An editor waiting for an article'][i]) for i,n in enumerate(backgrounds)])
save('traits',[dict(id=f'trait_{i}',name=n,stat=stats[i%9],bonus=8,cost_factor=.9 if n=='Frugal' else 1.0,stress_factor=1.2 if n=='Perfectionist' else 1.0) for i,n in enumerate(['Perfectionist','Hustler','Visionary','Diplomat','Risk-taker','Frugal','Charismatic','Stubborn','Patient','Resilient'])])
save('genres',[dict(id=f'genre_{i}',name=n,color=c,trend=.9+i*.04) for i,(n,c) in enumerate(zip(genres,['#52c7b8','#ed9566','#df8eb9','#859eef','#e6c86d','#80b7a2','#b79bdb','#b08b88']))])
save('economy',dict(currency='lakh BDT',version=1,starting_year=2026,stats=stats,districts=districts,genders=['Woman','Man','Non-binary','Prefer not to say'],tiers=[dict(name='Independent',budget=60,daily_cost=3.5,days=8,screens=20),dict(name='Commercial',budget=240,daily_cost=5.5,days=22,screens=60),dict(name='Event picture',budget=650,daily_cost=7.5,days=40,screens=120)],ticket=200,seats=230,shows=3,multiplex_share=.31,big_opening_share=.38,single_share=.20,multiplex_fraction=.35,decay=.69,wom_growth=.33,piracy=.08,max_run=8,pitch_base=.48,minimum_cash=-250,training_cost=3,recovery=16,royalty_rate=.15,loan_interest=.002,loan_amount=80,loan_limit=240,base_fee=8,rights_base=12,rights_quality=.5,rights_hype=.25,cast_quality=.10,script_quality=.38,direction_quality=.32,crew_quality=.20,occupancy_base=.10,occupancy_cast=.003,occupancy_hype=.003,occupancy_quality=.002,occupancy_cap=.95,quality_center=50,award_random=10,retirement_age=85))
templates=[('Monsoon delay','Rain threatens the schedule.','production','Schedule a covered set','Protect the location'),('Late arrival','A performer misses the call time.','production','Rehearse with stand-ins','Pay for transport'),('Leaked footage','Unfinished footage circulates online.','marketing','Release an official preview','Request a takedown'),('Creative disagreement','The team wants a different ending.','post','Listen and recut','Defend your vision'),('Investor hesitation','Your backer requests a revised forecast.','financing','Present a careful plan','Offer more backend'),('Festival invitation','A curator asks for a work in progress.','post','Send a private screener','Wait for the final cut'),('Viral conversation','A scene sparks an online discussion.','marketing','Join the conversation','Let the audience lead'),('Safety concern','A difficult setup needs extra care.','production','Bring a safety specialist','Simplify the scene'),('Permit question','A location official requests documents.','preproduction','Reschedule and comply','Move to a set'),('Rival announcement','Another film targets your release window.','distribution','Move the release','Keep the date'),('A mentor calls','An experienced filmmaker offers advice.','development','Listen closely','Exchange ideas'),('Unexpected repair','A piece of equipment needs servicing.','production','Rent a replacement','Change the shot list'),('Press interview','A journalist requests a conversation.','marketing','Discuss the craft','Discuss the audience'),('Fresh idea','A junior colleague suggests a scene.','development','Develop the idea','Keep the draft focused'),('Music opportunity','A song is attracting early attention.','marketing','Fund a lyric video','Arrange a live session')]
events=[]
for i in range(150):
 t=templates[i%15]; variant=i//15+1
 context=['The river unit has only a morning access window.','Your lead performer has a second booking next week.','A new collaborator is making their feature debut.','A holiday deadline leaves little room to move.','Your small team is working with borrowed equipment.','The producer asks you to protect the contingency fund.','A remote location has limited transport connections.','The crew has proposed a simpler, more intimate approach.','An international partner needs a delivery update.','Your distributor is comparing the plan with a rival release.'][variant-1]
 events.append(dict(id=f'event_{i}',name=f'{t[0]} · {variant:02d}',description=t[1]+' '+context,conditions=dict(stage=t[2],min_week=1+i//60),choices=[dict(label=t[3],cash=-float(1+i%6),quality=2+i%3,hype=1,stress=-2,relationship=2),dict(label=t[4],cash=0,quality=-1,hype=2+i%4,stress=3,relationship=-1)]))
save('events',events)
save('reviews',[dict(id='review_0',name='A difficult debut',min_quality=0,text='The ambition is visible, but the scattered storytelling struggles to connect.'),dict(id='review_1',name='Flashes of promise',min_quality=40,text='A few memorable scenes shine through an uneven film. There is a voice worth watching.'),dict(id='review_2',name='An assured storyteller',min_quality=60,text='Confident performances and a focused script make this a rewarding evening at the cinema.'),dict(id='review_3',name='A film that stays with you',min_quality=80,text='A vivid, emotionally precise film. The images linger long after the lights come up.')])
save('localization',dict(en=dict(new_career='New career',continue_game='Continue',settings='Settings',next_week='Next week',title='THE DIRECTOR',subtitle='Dhallywood',welcome='Your next story starts here.'),bn=dict(new_career='নতুন ক্যারিয়ার',continue_game='চালিয়ে যান',settings='সেটিংস',next_week='পরের সপ্তাহ',title='দ্য ডিরেক্টর',subtitle='ঢালিউড',welcome='আপনার পরবর্তী গল্প এখানেই শুরু।')))
save('content',dict(themes=['Belonging','Justice','Ambition','Family','Memory','Love'],tones=['Hopeful','Gritty','Playful','Melancholic'],eras=['Present day','1990s','1971','Near future'],ratings=['U','12+','18+'],sources=['Original screenplay','Buy a script','Book adaptation','Remake','Sequel','Reboot'],stages=['development','financing','packaging','preproduction','production','post','marketing','distribution','release','complete'],stage_labels=['Development','Financing','Cast & crew','Pre-production','Production','Post & censor','Marketing','Distribution','In cinemas','Completed'],stage_weeks=[3,1,1,2,4,3,2,1,8,0],rival_titles=['River of Light','Midnight Dhaka','Last Ferry','Paper Kingdom','A Monsoon Letter','Blue Rickshaw','The Other Shore','City of Songs'],tips=['Write your own story, then advance development with Next week.','Pitch a backer or self-finance. A rejection is a chance to revise.','Cast and crew fees count against your production budget.','Let the schedule complete, then begin shooting.','Protect your stamina: rushing costs quality and increases stress.','Review rating cuts before releasing your final edit.','Hype helps opening weekend; quality sustains later weeks.','Choose screens, a release window and rights deals carefully.','Producer receipts differ from headline box-office gross.','Campaign for awards, license your catalog or begin a sequel.'],credits=['Design, code and procedural artwork: THE DIRECTOR project','All characters and calibration films are fictional. Financial values are estimates.','Noto Sans Bengali — SIL Open Font License 1.1','Godot Engine — MIT License','GUT by bitwes — MIT License','Procedural music and sounds created for this project. No external stock art.']))
# Machine-readable schemas for every document; custom validator additionally checks references and ranges.
record={'type':'object','required':['id','name'],'properties':{'id':{'type':'string','minLength':1},'name':{'type':'string','minLength':1}}}
schemas={p.stem:({'type':'object'} if p.stem in ['economy','localization','content'] else {'type':'array','minItems':1,'items':record}) for p in ROOT.glob('*.json') if p.stem!='schemas'}
schemas['events']['items']={'type':'object','required':['id','name','conditions','description','choices'],'properties':{'id':{'type':'string'},'name':{'type':'string'},'conditions':{'type':'object','required':['stage','min_week']},'choices':{'type':'array','minItems':2,'maxItems':3,'items':{'type':'object','required':['label','cash','quality','hype','stress','relationship']}}}}
def infer(value):
 if isinstance(value,bool):return {'type':'boolean'}
 if isinstance(value,str):return {'type':'string'}
 if isinstance(value,(int,float)):return {'type':'number'}
 if isinstance(value,list):return {'type':'array','items':infer(value[0]) if value else {}}
 if isinstance(value,dict):return {'type':'object','required':list(value),'properties':{k:infer(v) for k,v in value.items()}}
 raise TypeError(type(value))
for p in ROOT.glob('*.json'):
 if p.stem=='schemas':continue
 content=json.loads(p.read_text())
 schema=infer(content)
 schema['$schema']='https://json-schema.org/draft/2020-12/schema'
 if isinstance(content,list):
  schema['minItems']=1
  props=schema['items']['properties']
  props['id']['minLength']=1;props['name']['minLength']=1
  for name in ['skill','reputation']:
   if name in props:props[name].update(minimum=0,maximum=100)
  if 'availability' in props:props['availability'].update(minimum=0,maximum=1)
  if 'fee_range' in props:props['fee_range'].update(minItems=2,maxItems=2)
  if p.stem=='events':
   props['choices'].update(minItems=2,maxItems=3)
   props['conditions']['properties']['stage']['enum']=['development','financing','packaging','preproduction','production','post','marketing','distribution']
 schemas[p.stem]=schema
save('schemas',schemas)
print('Generated',len(schemas),'data documents')
