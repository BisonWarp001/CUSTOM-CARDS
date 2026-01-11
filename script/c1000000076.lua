--The Eye of the Pyramid
local s,id=GetID()

function s.initial_effect(c)
	--Activate: Place 1 "Pyramid of Light" from Deck or GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	--Once per turn: shuffle 1 "Sphinx" from GY or banishment into Deck, then draw 1
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end

--Listed card
s.listed_names={53569894} -- Pyramid of Light

--=====================
-- Activation: Place Pyramid of Light
--=====================
function s.plfilter(c,tp)
	return c:IsCode(53569894)
		and not c:IsForbidden()
		and c:CheckUniqueOnField(tp)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(
		tp,
		aux.NecroValleyFilter(s.plfilter),
		tp,
		LOCATION_DECK|LOCATION_GRAVE,
		0,1,1,nil,tp
	):GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end

--=====================
-- Shuffle Sphinx → Draw
--=====================
function s.tdfilter(c)
	return c:IsMonster()
		and c:IsSetCard(0x5c) -- Sphinx
		and c:IsAbleToDeck()
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			s.tdfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil)
			and Duel.IsPlayerCanDraw(tp,1)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(
		tp,
		s.tdfilter,
		tp,
		LOCATION_GRAVE|LOCATION_REMOVED,
		0,1,1,nil)
	if #g>0 then
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
