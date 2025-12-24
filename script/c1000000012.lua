--The True Power (Quick-Play Spell)
local s,id=GetID()
function s.initial_effect(c)
	local EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF =
		EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE

	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

-- Listed names
s.listed_names={10000000,10000010,10000020}

function s.obeliskfilter(c)
    return c:IsFaceup() and c:IsOriginalCodeRule(10000000)
        and c:IsOriginalAttribute(ATTRIBUTE_DIVINE)
end
function s.sliferfilter(c)
    return c:IsFaceup() and c:IsOriginalCodeRule(10000020)
end
function s.ra_filter(c)
    return c:IsFaceup() and (c:IsOriginalCodeRule(10000010) or c:IsOriginalCodeRule(10000090))
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.obeliskfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.obeliskfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.sliferfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.ra_filter,tp,LOCATION_MZONE,0,1,1,nil)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Seleccionar Obelisk
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local ob=Duel.SelectMatchingCard(tp,s.obeliskfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if not ob then return end

	--Seleccionar Slifer
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sl=Duel.SelectMatchingCard(tp,s.sliferfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if not sl then return end

	--Seleccionar Ra
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local ra=Duel.SelectMatchingCard(tp,s.ra_filter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if not ra then return end

	--Sumar ATK/DEF actuales
	local atk = math.max(sl:GetAttack(),0) + math.max(ra:GetAttack(),0)
	local def = math.max(sl:GetDefense(),0) + math.max(ra:GetDefense(),0)

	--Aplicar boosts
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	ob:RegisterEffect(e1)

	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(def)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	ob:RegisterEffect(e2)
	
	--Tributar Slifer y Ra
	local g=Group.FromCards(sl,ra)
	Duel.Release(g,REASON_EFFECT)
end
