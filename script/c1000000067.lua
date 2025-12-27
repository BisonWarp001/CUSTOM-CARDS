--Unholy Synchronicity of the Wicked
local s,id=GetID()
local PROT = EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE

function s.initial_effect(c)
	--------------------------------
	-- Activate
	--------------------------------
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetProperty(PROT)
	c:RegisterEffect(e0)

	--------------------------------
	-- Cannot be destroyed by effects while controlling any Wicked
	--------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(PROT)
	e1:SetCondition(s.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)

	--------------------------------
	-- Immunity: Avatar & Eraser unaffected by Dreadroot’s effects
	--------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetProperty(PROT)
	e2:SetTarget(s.immtg1)
	e2:SetValue(s.immval1)
	c:RegisterEffect(e2)

	--------------------------------
	-- Immunity: Avatar & Dreadroot unaffected by Eraser’s effects
	--------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetProperty(PROT)
	e3:SetTarget(s.immtg2)
	e3:SetValue(s.immval2)
	c:RegisterEffect(e3)

	--------------------------------
	-- You can only control 1 of this card
	--------------------------------
	c:SetUniqueOnField(1,0,id)
end

--------------------------------
-- Listed names
--------------------------------
s.listed_names={21208154,62180201,57793869}
-- Avatar, Dreadroot, Eraser

--------------------------------
-- Condition: card cannot be destroyed by effects while controlling any Wicked
--------------------------------
function s.indfilter(c)
	return c:IsFaceup() and c:IsCode(21208154,62180201,57793869)
end
function s.indcon(e)
	return Duel.IsExistingMatchingCard(s.indfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

--------------------------------
-- (1) Avatar & Eraser unaffected by Dreadroot's effects
--------------------------------
function s.immtg1(e,c)
	return c:IsFaceup() and c:IsCode(21208154,57793869) -- Avatar, Eraser
end
function s.immval1(e,te)
	local tc=te:GetHandler()
	return tc:IsControler(e:GetHandlerPlayer()) and tc:IsCode(62180201)
end


--------------------------------
-- (2) Avatar & Dreadroot unaffected by Eraser's effects
--------------------------------
function s.immtg2(e,c)
	return c:IsFaceup() and c:IsCode(21208154,62180201) -- Avatar, Dreadroot
end
function s.immval2(e,te)
	local tc=te:GetHandler()
	return te:IsActiveType(TYPE_MONSTER)
		and tc:IsControler(e:GetHandlerPlayer())
		and tc:IsCode(57793869) -- Eraser
end
