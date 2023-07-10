
% Begin distance

distance(Agent, TargetAgent, Distance):- Distance is abs(Agent.x - TargetAgent.x) + abs(Agent.y - TargetAgent.y). 
% Find the Manhattan Distance is found by the formula.

% End distance, begin multiverse_distance
	
multiverse_distance_state(warrior, Class) :- Class = warrior.   %These predicates check the classes of agents by its name.
multiverse_distance_state(wizard, Class) :- Class = wizard. 	%These predicates check the classes of agents by its name.
multiverse_distance_state(rogue, Class) :- Class = rogue. 	 	%These predicates check the classes of agents by its name.
multiverse_distance(StateId, AgentId, TargetStateId, TargetAgentId, Distance) :- 
	state(StateId, Agents,_,_), state(TargetStateId, TargetAgents,_,_), Agent = Agents.get(AgentId), TargetAgent = TargetAgents.get(TargetAgentId),
	history(StateId, UniverseID, Time ,_), history(TargetStateId, TargetUniverseID, TargetTime ,_), multiverse_distance_state(warrior, Agent.class),
	Distance is abs(Agent.x - TargetAgent.x) + abs(Agent.y - TargetAgent.y) + 5 * abs(Time - TargetTime) + 5 * abs(UniverseID - TargetUniverseID).
multiverse_distance(StateId, AgentId, TargetStateId, TargetAgentId, Distance) :- 
	state(StateId, Agents,_,_), state(TargetStateId, TargetAgents,_,_), Agent = Agents.get(AgentId), TargetAgent = TargetAgents.get(TargetAgentId),
	history(StateId, UniverseID, Time ,_), history(TargetStateId, TargetUniverseID, TargetTime ,_), multiverse_distance_state(wizard, Agent.class),
	Distance is abs(Agent.x - TargetAgent.x) + abs(Agent.y - TargetAgent.y) + 2 * abs(Time - TargetTime) + 2 * abs(UniverseID - TargetUniverseID).
multiverse_distance(StateId, AgentId, TargetStateId, TargetAgentId, Distance) :- 
	state(StateId, Agents,_,_), state(TargetStateId, TargetAgents,_,_), Agent = Agents.get(AgentId), TargetAgent = TargetAgents.get(TargetAgentId),
	history(StateId, UniverseID, Time ,_), history(TargetStateId, TargetUniverseID, TargetTime ,_), multiverse_distance_state(rogue, Agent.class),
	Distance is abs(Agent.x - TargetAgent.x) + abs(Agent.y - TargetAgent.y) + 5 * abs(Time - TargetTime) + 5 * abs(UniverseID - TargetUniverseID).
	
% Find the distance after checking the agents' classes.

% End multiverse_distance, begin nearest_agent
	
first_pair([Dist-Key-_|_], Dist, Key).	% This predicate enables one to return the first two parts of the first element of a list.
not_equals(Elem1,Elem2) :- \+ (Elem1 = Elem2).
nearest_agent(StateId, AgentId, NearestAgentId, Distance) :-
	state(StateId, Agents,_,_), state(StateId, TargetAgents,_,_), Agent = Agents.get(AgentId), dict_pairs(TargetAgents,_ ,TargetList),
	findall(Dist-Key-Value, (member(Key-Value, TargetList), distance(Agent, TargetAgents.get(Key),Dist),not_equals(TargetAgents.get(Key).name, Agent.name)), NewList), 
	sort(NewList, MinList), first_pair(MinList, MinValue, MinKey), NearestAgentId is MinKey, Distance is MinValue.

% End nearest_agent, begin nearest_agent_in_multiverse

first_pair_in_multiverse([Dist-ID-Key-_|_], Dist, ID, Key).% This predicate enables one to return the first 3 parts of the first element of a list.
nearest_agent_in_multiverse(StateId, AgentId, TargetStateId, TargetAgentId, Distance):-
	state(StateId,Agents,_,_), findall(Dist-Target-Key-Value, 
		(state(Target, TargetAgents,_, _), dict_pairs(TargetAgents,_, TargetList), member(Key-Value, TargetList), 
		multiverse_distance(StateId, AgentId, Target, Key, Dist),not_equals(TargetAgents.get(Key).name, Agents.get(AgentId).name)), NewList),
	sort(NewList, MinList), first_pair_in_multiverse(MinList, MinValue, MinID, MinKey), 
	TargetStateId is MinID, TargetAgentId is MinKey, Distance is MinValue.

% End nearest_agent_in_multiverse, begin num_agents_in_state

list_length([], 0).				% This predicate iteratively finds the length of a list.
list_length([_ | Tail], Length) :- list_length(Tail, TempLength), Length is TempLength + 1.  
equals(Elem1,Elem2) :- Elem1 = Elem2.
num_agents_in_state(StateId, Name, NumWarriors, NumWizards, NumRogues) :- % Finds the warriors, wizards and rogues separately.
	state(StateId , Agents,_,_), dict_pairs(Agents, _, AgentsIterable),   % Then assign the lengths to related variable.
	findall(Key-Value, (member(Key-Value,AgentsIterable), not_equals(Name, Agents.get(Key).name)), NewList),
	findall(Key-Value, (member(Key-Value, NewList), equals(warrior, Agents.get(Key).class)), WarriorList),
	findall(Key-Value, (member(Key-Value, NewList), equals(wizard, Agents.get(Key).class)), WizardList),
	findall(Key-Value, (member(Key-Value, NewList), equals(rogue, Agents.get(Key).class)), RogueList),	
	list_length(WarriorList, WarriorNum), list_length(WizardList, WizardNum), list_length(RogueList, RogueNum),
	NumWarriors is WarriorNum, NumWizards is WizardNum, NumRogues is RogueNum.

% End num_agents_in_state, begin difficulty_of_state

% Finds the difficulties with controlling every single Agent.
difficulty_of_state(StateId, Name, AgentClass, Difficulty) :- multiverse_distance_state(warrior, AgentClass),
	num_agents_in_state(StateId, Name, NumWarriors, NumWizards, NumRogues), Difficulty is 5 * NumWarriors + 8 * NumWizards + 2 * NumRogues.
difficulty_of_state(StateId, Name, AgentClass, Difficulty) :- multiverse_distance_state(wizard, AgentClass),
	num_agents_in_state(StateId, Name, NumWarriors, NumWizards, NumRogues), Difficulty is 2 * NumWarriors + 5 * NumWizards + 8 * NumRogues.
difficulty_of_state(StateId, Name, AgentClass, Difficulty) :- multiverse_distance_state(rogue, AgentClass),
	num_agents_in_state(StateId, Name, NumWarriors, NumWizards, NumRogues), Difficulty is 8 * NumWarriors + 2 * NumWizards + 5 * NumRogues.

% End difficulty_of_state, begin easiest_traversable_state

first_pair_easiest([Diff-ID|_], Diff, ID). % This predicate allows one to reach the parts of the first element of a list.

able_to_portal(Agent, StateId, TargetStateId) :-  % Checking portalling conditions.
	state(StateId,_, _, TurnOrder),
	history(StateId, UniverseId, Time, _), history(TargetStateId, TargetUniverseId, TargetTime, _),
	global_universe_id(GlobalUniverseId), universe_limit(UniverseLimit), GlobalUniverseId < UniverseLimit,
	length(TurnOrder, NumAgents), NumAgents > 1, current_time(TargetUniverseId, TargetUniCurrentTime, _),
	TargetTime < TargetUniCurrentTime, (Agent.class = wizard -> TravelCost = 2; TravelCost = 5), 
	Cost is abs(TargetTime - Time)*TravelCost + abs(TargetUniverseId - UniverseId)*TravelCost, Agent.mana >= Cost,
	state(TargetStateId, TargetAgents, _, TargetTurnOrder),
	TargetState = state(TargetStateId, TargetAgents, _, TargetTurnOrder), \+tile_occupied(Agent.x, Agent.y, TargetState).

able_to_portal_to_now(Agent, StateId, TargetStateId) :- % Checking portalling conditions.
	state(StateId,_, _, TurnOrder),
	history(StateId, UniverseId, Time, _), history(TargetStateId, TargetUniverseId, TargetTime, _),
	TargetState = state(TargetStateId, TargetAgents, _, TargetTurnOrder), 
	length(TurnOrder, NumAgents), NumAgents > 1,
	current_time(TargetUniverseId, TargetTime, 0), \+(TargetUniverseId = UniverseId), (Agent.class = wizard -> TravelCost = 2; TravelCost = 5),
	Cost is abs(TargetTime - Time)*TravelCost + abs(TargetUniverseId - UniverseId)*TravelCost, Agent.mana >= Cost,
	get_latest_target_state(TargetUniverseId, TargetTime, TargetStateId), state(TargetStateId, TargetAgents, _, TargetTurnOrder),
	\+tile_occupied(Agent.x, Agent.y, TargetState).
			
easiest_traversable_state(StateId, AgentId, TargetStateId) :- state(StateId, Agents,_,_), Agent = Agents.get(AgentId) ,
	findall(Difficulty-Target, (history(Target,_,_,_), difficulty_of_state(Target, Agent.name, Agent.class, Difficulty), Difficulty > 0,
	(able_to_portal(Agent, StateId, Target); able_to_portal_to_now(Agent, StateId, Target); Target = StateId)), DifficultList),
	sort(DifficultList,MinList), first_pair_easiest(MinList, _, ID), TargetStateId is ID.

% End easiest_traversable_state, begin basic_action_policy

basic_action_policy(StateId, AgentId, Action) :- 

	state(StateId, Agents,_,_), Agent = Agents.get(AgentId), multiverse_distance_state(warrior, Agent.class), (
	((easiest_traversable_state(StateId, AgentId, TargetID), able_to_portal_to_now(Agent, StateId, TargetID), history(TargetID, UniverseID, _, _)) -> Action=[portal_to_now, UniverseID]);
	((easiest_traversable_state(StateId, AgentId, TargetID), able_to_portal(Agent, StateId, TargetID), history(TargetID, UniverseID, Time, _)) -> Action = [portal, UniverseID, Time]) ;
	((nearest_agent(StateId, AgentId, NearestId, Dist), Dist =< 1) -> Action = [melee_attack, NearestId]); 
	((Agents.get(NearestId).x < Agent.x) -> Action = [move_left]);
	((Agents.get(NearestId).x > Agent.x) -> Action = [move_right]);
	((Agents.get(NearestId).y < Agent.y) -> Action = [move_down]);
	((Agents.get(NearestId).y > Agent.y) -> Action = [move_up]);
	(Action = [rest])).

basic_action_policy(StateId, AgentId, Action) :- 
	state(StateId, Agents,_,_), Agent = Agents.get(AgentId), multiverse_distance_state(wizard, Agent.class), (
	((easiest_traversable_state(StateId, AgentId, TargetID), able_to_portal_to_now(Agent, StateId, TargetID), history(TargetID, UniverseID, _, _)) -> Action=[portal_to_now, UniverseID]);
	((easiest_traversable_state(StateId, AgentId, TargetID), able_to_portal(Agent, StateId, TargetID), history(TargetID, UniverseID, Time, _)) -> Action = [portal, UniverseID, Time]) ;
	((nearest_agent(StateId, AgentId, NearestId, Dist), Dist =< 10) -> Action = [magic_missile, NearestId]); 
	((Agents.get(NearestId).x < Agent.x) -> Action = [move_left]);
	((Agents.get(NearestId).x > Agent.x) -> Action = [move_right]);
	((Agents.get(NearestId).y < Agent.y) -> Action = [move_down]);
	((Agents.get(NearestId).y > Agent.y) -> Action = [move_up]);
	(Action = [rest])).


basic_action_policy(StateId, AgentId, Action) :- 
	state(StateId, Agents,_,_), Agent = Agents.get(AgentId), multiverse_distance_state(rogue, Agent.class), (
	((easiest_traversable_state(StateId, AgentId, TargetID), able_to_portal_to_now(Agent, StateId, TargetID), history(TargetID, UniverseID, _, _)) -> Action=[portal_to_now, UniverseID]);
	((easiest_traversable_state(StateId, AgentId, TargetID), able_to_portal(Agent, StateId, TargetID), history(TargetID, UniverseID, Time, _)) -> Action = [portal, UniverseID, Time]) ;
	((nearest_agent(StateId, AgentId, NearestId, Dist), Dist =< 5) -> Action = [ranged_attack, NearestId]); 
	((Agents.get(NearestId).x < Agent.x) -> Action = [move_left]);
	((Agents.get(NearestId).x > Agent.x) -> Action = [move_right]);
	((Agents.get(NearestId).y < Agent.y) -> Action = [move_down]);
	((Agents.get(NearestId).y > Agent.y) -> Action = [move_up]);
	(Action = [rest])).

%Find the action by checking the agents' classes.
