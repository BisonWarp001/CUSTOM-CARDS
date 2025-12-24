--Orichalcos Deuteros
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	-------------------------------------------------
	-- Activate
	-------------------------------------------------
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	-------------------------------------------------
	-- Gain LP during your End Phase
	-------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.lpcon)
	e1:SetOperation(s.lpop)
	c:RegisterEffect(e1)

	-------------------------------------------------
	-- "The Ultimate Seal of Orichalcos" protection
	-------------------------------------------------
	-- Cannot be targeted by card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_SZONE,0)
	e2:SetTarget(s.sealtg)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)

	-- Cannot be destroyed by card effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_SZONE,0)
	e3:SetTarget(s.sealtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end

-------------------------------------------------
-- Filters / Conditions
-------------------------------------------------

-- "The Seal of Orichalcos"
function s.sealfilter(c)
	return c:IsFaceup() and c:IsCode(48179391)
end

-- Must control the Seal
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
		and Duel.IsExistingMatchingCard(s.sealfilter,tp,LOCATION_ONFIELD,0,1,nil)
end


-- Gain 500 LP per monster you control
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(Card.IsMonster,tp,LOCATION_MZONE,0,nil)
	if ct>0 then
		Duel.Recover(tp,ct*500,REASON_EFFECT)
	end
end


-- Protect only "The Seal of Orichalcos"
function s.sealtg(e,c)
	return c:IsCode(48179391)
end
