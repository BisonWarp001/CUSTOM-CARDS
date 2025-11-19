--The Pharaoh of Legend
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon: 1 Level 10 monster
	Link.AddProcedure(c,nil,1,1,s.matfilter)

	---------------------------------------
	-- EFFECT 1 — Banish up to 3 from DECK / SS same number Level 4 or less from DECK (DEF)
	---------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	---------------------------------------
	-- EFFECT 2 — Tribute to search Divine-Beast or S/T that mentions them (from DECK or GY)
	---------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

-- Cards referenced (Egyptian Gods)
s.listed_names={10000000,10000020,10000010}

-- Material: 1 Level 10 monster
function s.matfilter(c,lc,sumtype,tp)
	return c:IsLevel(10)
end

---------------------------------------
-- EFFECT 1 helpers
---------------------------------------

-- Trigger condition: Link Summoned
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

-- Banishable from deck (we only allow deck here; selection pool is Deck)
function s.banishfilter(c)
	return c:IsAbleToRemove()
end

-- Level 4 or less monsters in deck that can be SS
function s.summonfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end

-- Selection check: given a chosen banish group (sg from deck), ensure that AFTER banishing those,
-- there remain at least #sg monsters in deck that satisfy summonfilter (i.e. you can SS exactly that many).
-- Also ensure there are enough Monster Zones to SS that many.
function s.spcheck(sg,e,tp,mg)
	local ct=#sg
	-- Check MZONE available (banishing from deck doesn't free zones, so normal count)
	if Duel.GetLocationCount(tp,LOCATION_MZONE) < ct then return false end

	-- Count available Level4-or-less summonable monsters in deck excluding those that would be banished (sg)
	local dg=Duel.GetMatchingGroup(s.summonfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- subtract those in sg that are also valid summon targets
	local overlap=sg:FilterCount(function(c) return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end, nil)
	return dg:GetCount() - overlap >= ct
end

---------------------------------------
-- EFFECT 1 target & operation
---------------------------------------
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- pool: Deck only for banish
	local g=Duel.GetMatchingGroup(s.banishfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then
		return aux.SelectUnselectGroup(g,e,tp,1,3,s.spcheck,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local deckg=Duel.GetMatchingGroup(s.banishfilter,tp,LOCATION_DECK,0,nil)
	if #deckg==0 then return end

	local maxct=3
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then maxct=1 end

	-- select 1..maxct cards from DECK to banish; selection validated by s.spcheck
	local rg=aux.SelectUnselectGroup(deckg,e,tp,1,maxct,s.spcheck,1,tp,HINTMSG_REMOVE)
	if not rg or #rg==0 then return end

	-- Banish the selected cards face-up
	if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)==0 then return end

	-- Number actually banished
	local removed=#Duel.GetOperatedGroup()
	if removed<=0 then return end

	-- Check MZONE and adjust removed if zones limited (should not happen due to spcheck but be safe)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if removed>ft then removed=ft end

	-- Select exactly 'removed' Level4 or less monsters from Deck (these now exclude the banished ones)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(function(card) return s.summonfilter(card,e,tp) end),tp,LOCATION_DECK,0,removed,removed,nil)
	-- If NecroValleyFilter not necessary, above still works; it's safe to keep
	if #sg==0 then return end

	-- Special Summon them in Defense Position
	for tc in aux.Next(sg) do
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	Duel.SpecialSummonComplete()

	-- Restriction: Only DIVINE monsters can be Summoned/Set for the rest of the turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,tp)

	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_MSET)
	Duel.RegisterEffect(e3,tp)

	local hint=Effect.CreateEffect(c)
	hint:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	hint:SetDescription(aux.Stringid(id,2) or aux.Stringid(id,0))
	hint:SetReset(RESET_PHASE+PHASE_END)
	hint:SetTargetRange(1,0)
	Duel.RegisterEffect(hint,tp)
end

function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_DIVINE)
end

---------------------------------------
-- EFFECT 2 — Tribute to search
---------------------------------------
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end

-- Filter: exact god monsters OR S/T that mentions them (search from Deck or Grave)
function s.thfilter(c)
	-- direct god monsters by code
	if (c:IsCode(10000000) or c:IsCode(10000020) or c:IsCode(10000010)) and c:IsAbleToHand() then
		return true
	end
	-- Spell/Trap that mentions the gods
	if c:IsType(TYPE_SPELL+TYPE_TRAP) and (c:ListsCode(10000000) or c:ListsCode(10000020) or c:ListsCode(10000010)) and c:IsAbleToHand() then
		return true
	end
	return false
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
