--Transcendental Legacy
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id) -- only once per turn
	e1:SetCondition(s.condition) -- no Extra Deck summon this turn
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

--Condition: You have not Special Summoned from Extra Deck this turn
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 or not Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_SPECIAL_SUMMON)
end

--Filter for Special Summon from Deck
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelAbove(1)
end

--Check function for aux.SelectUnselectGroup: sum of levels <= lv
function s.spcheck(sg,lv)
	return sg:GetSum(Card.GetLevel)<=lv
end

--Target: send 1 monster from hand
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

--Activate: send monster, Special Summon 1 or more from Deck whose total Levels <= sent monster's level
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,1,nil)
	if #g==0 then return end
	local tc=g:GetFirst()
	local lv=tc:GetLevel()
	if Duel.SendtoGrave(tc,REASON_EFFECT)==0 then return end
	
	--Prevent Extra Deck summons for the rest of the turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	
	--Get all valid monsters from Deck
	local dg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if #dg==0 then return end

	--Use SelectUnselectGroup to pick multiple monsters whose total Levels <= lv
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>#dg then ft=#dg end

	local sg=aux.SelectUnselectGroup(dg,e,tp,1,ft,function(g) return s.spcheck(g,lv) end,1,tp,HINTMSG_SPSUMMON)
	if #sg==0 then return end

	--Special Summon selected monsters
	for tc in aux.Next(sg) do
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	Duel.SpecialSummonComplete()
end
