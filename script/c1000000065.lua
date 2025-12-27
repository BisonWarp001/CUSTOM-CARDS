-- Obelisk the Progenitor
local s,id=GetID()

function s.initial_effect(c)
	-------------------------------------------------------
	-- ACTIVATE (CANNOT BE NEGATED)
	-------------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id) -- once per Duel
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
	e1:SetCondition(s.actcon)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

s.listed_names={10000000}

-------------------------------------------------------
-- CONDITION: CONTROL OBELISK (ORIGINAL DIVINE)
-------------------------------------------------------
function s.obfilter(c)
	return c:IsFaceup()
		and c:IsCode(10000000) -- Obelisk the Tormentor
		and c:GetOriginalAttribute()==ATTRIBUTE_DIVINE
end

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.obfilter,tp,LOCATION_MZONE,0,1,nil)
end

-------------------------------------------------------
-- COST: TRIBUTE 2 OTHER FACE-UP MONSTERS
-------------------------------------------------------
function s.costfilter(c)
	return c:IsFaceup()
		and c:IsReleasable()
		and not c:IsCode(10000000)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.CheckReleaseGroup(tp,s.costfilter,2,nil)
	end
	local g=Duel.SelectReleaseGroup(tp,s.costfilter,2,2,nil)
	Duel.Release(g,REASON_COST)
end

-------------------------------------------------------
-- TARGET
-------------------------------------------------------
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.obfilter,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
	local g=Duel.SelectMatchingCard(tp,s.obfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetTargetCard(g)
end

-------------------------------------------------------
-- OPERATION
-------------------------------------------------------
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	local c=e:GetHandler()

	---------------------------------------------------
	-- EFFECTS OF OBELISK CANNOT BE NEGATED
	---------------------------------------------------
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_DISABLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
	tc:RegisterEffect(e0)

	---------------------------------------------------
	-- INFINITE ATK (SIMULATED)
	---------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(9999999)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
	tc:RegisterEffect(e1)

	---------------------------------------------------
	-- PIERCING DAMAGE
	---------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
	tc:RegisterEffect(e2)

	---------------------------------------------------
	-- ACTIVATE LOCK (Ancient Gear–style)
	---------------------------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(s.aclimit)
	e3:SetCondition(s.actcon1)
	e3:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
	tc:RegisterEffect(e3)
end

-------------------------------------------------------
-- ACTIVATE LOCK CONDITION
-------------------------------------------------------
function s.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsMonsterEffect()
end

function s.actcon1(e)
	return Duel.GetAttacker()==e:GetHandler()
end
