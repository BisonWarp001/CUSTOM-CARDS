--Orichalcos Matia
local s,id=GetID()
function s.initial_effect(c)
	--Activate: Pay 800 LP; add 1 "Orichalcos" card from Deck to hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)

	--GY effect: Banish this card; shuffle 3 "Orichalcos" cards and draw 1
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(s.gycost)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	e2:SetCountLimit(1,id+100)
	c:RegisterEffect(e2)
end

-------------------------------------------------
-- Cost: Pay 800 LP
-------------------------------------------------
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	Duel.PayLPCost(tp,800)
end

-------------------------------------------------
-- Search filter
-------------------------------------------------
function s.thfilter(c)
	return c:IsSetCard(0x3e8)
		and not c:IsCode(id)
		and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-------------------------------------------------
-- GY cost: banish this card
-------------------------------------------------
function s.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end

-------------------------------------------------
-- GY target
-------------------------------------------------
function s.tdfilter(c)
	return c:IsSetCard(0x3e8)
		and not c:IsCode(id)
		and c:IsAbleToDeck()
end

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tdfilter,tp,
			LOCATION_GRAVE+LOCATION_REMOVED,0,3,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,
		LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,
		LOCATION_GRAVE+LOCATION_REMOVED,0,3,3,nil)
	if #g==3 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		if Duel.GetOperatedGroup():IsExists(Card.IsLocation,1,nil,
			LOCATION_DECK+LOCATION_EXTRA) then
			Duel.ShuffleDeck(tp)
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
