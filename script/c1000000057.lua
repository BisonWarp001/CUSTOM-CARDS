--Dimensional Seal of Orichalcos
local s,id=GetID()
function s.initial_effect(c)
	-------------------------------------------------
	-- Activate (Continuous Trap)
	-------------------------------------------------
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	-------------------------------------------------
	-- Extra Deck Special Summon restriction
	-------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(1,1)
	e1:SetCondition(s.edcon)
	e1:SetTarget(s.edlimit)
	c:RegisterEffect(e1)

	-------------------------------------------------
	-- LP maintenance (INDEPENDENT)
	-------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.lpcon)
	e2:SetOperation(s.lpop)
	c:RegisterEffect(e2)
end

-------------------------------------------------
-- Conditions / Filters
-------------------------------------------------

-- Check for "The Ultimate Seal of Orichalcos"
function s.sealfilter(c)
	return c:IsFaceup() and c:IsCode(48179391)
end

-- Restriction ONLY applies while you control the Seal
function s.edcon(e)
	return Duel.IsExistingMatchingCard(
		s.sealfilter,
		e:GetHandlerPlayer(),
		LOCATION_ONFIELD,
		0,
		1,
		nil
	)
end

-- Only "Orichalcos" monsters can be Special Summoned from Extra Deck
function s.edlimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x3e8)
end

-------------------------------------------------
-- LP maintenance
-------------------------------------------------

-- Only during your Standby Phase
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end

function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.CheckLPCost(tp,1000)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.PayLPCost(tp,1000)
	else
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
