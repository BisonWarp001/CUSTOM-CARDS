-- The Eraser's Dominion
local s,id=GetID()

function s.initial_effect(c)
	-- Activate: Search + Extra Tribute Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	-- GY: Banish; damage when Eraser destroys cards
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(s.damcon)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
end

s.listed_names={57793869} -- The Wicked Eraser

-------------------------------------------------
-- Search Wicked Eraser
-------------------------------------------------
function s.thfilter(c)
	return c:IsCode(57793869) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- Add Eraser
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g==0 then return end
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g)

	-- Extra Tribute Summon (Ancient Chant pattern)
	if Duel.GetFlagEffect(tp,id)~=0 then return end

	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsLevelAbove,5))
	e1:SetValue(0x1)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)

	local e2=e1:Clone()
	e2:SetCode(EFFECT_EXTRA_SET_COUNT)
	Duel.RegisterEffect(e2,tp)

	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
end

-------------------------------------------------
-- GY damage effect
-------------------------------------------------
function s.eraserfilter(c)
	return c:IsFaceup() and c:IsCode(57793869)
end

function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.eraserfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	-- Register damage listener for this turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(s.damcond)
	e1:SetOperation(s.damcalc)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

-- Check destruction by Wicked Eraser's effect
function s.damcond(e,tp,eg,ep,ev,re,r,rp)
	local rc=re and re:GetHandler()
	return rc and rc:IsCode(57793869) and r&REASON_EFFECT~=0
end

function s.damcalc(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(Card.IsReason, nil, REASON_EFFECT)
	if ct>0 then
		Duel.Damage(1-tp,ct*1000,REASON_EFFECT)
	end
end
