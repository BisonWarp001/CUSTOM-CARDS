--Ultimate Egyptian God Slime
local s,id=GetID()
function s.initial_effect(c)
	---------------------------------------
	-- Fusion Summon procedure
	---------------------------------------
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,42166000,aux.FilterBoolFunction(Card.IsRace,RACE_DIVINE))

	---------------------------------------
	-- Alternative Special Summon (Tribute)
	---------------------------------------
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.altcon)
	e0:SetOperation(s.altop)
	c:RegisterEffect(e0)

	---------------------------------------
	-- Cannot be destroyed by battle
	---------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)

	---------------------------------------
	-- Unaffected by other card effects
	---------------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetOperation(s.immop)
	c:RegisterEffect(e3)

---------------------------------------
-- Gain 500 ATK/DEF when opponent activates an effect (AUTOMATIC)
---------------------------------------
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e4:SetCondition(s.gaincon)
	e4:SetOperation(s.gainop)
	c:RegisterEffect(e4)



end

--------------------------------------------------
-- Alternative Summon condition
--------------------------------------------------
function s.altcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,42166000)
		and Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,RACE_DIVINE)
end


function s.altop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g1=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,42166000)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g2=Duel.SelectMatchingCard(tp,Card.IsRace,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,RACE_DIVINE)
	g1:Merge(g2)
	Duel.Release(g1,REASON_COST+REASON_MATERIAL)
end

--------------------------------------------------
-- Immunity
--------------------------------------------------
function s.immop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(function(e,te) return te:GetOwner()~=e:GetOwner() end)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	c:RegisterEffect(e1)
end

--------------------------------------------------
-- Gain ATK/DEF
--------------------------------------------------
function s.gaincon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp
end

function s.gainop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(1000)
	e1:SetReset(RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)

	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
end
