--Orichalcos Leviathan
local s,id=GetID()

function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,0,id)

	-------------------------------------------------
	-- Fusion: 5+ "Orichalcos" monsters
	-------------------------------------------------
	Fusion.AddProcMixRep(c,true,true,
		aux.FilterBoolFunction(Card.IsSetCard,0x3e8),
		5,99)

	-------------------------------------------------
	-- Must be Fusion Summoned
	-------------------------------------------------
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)

	-------------------------------------------------
	-- Unaffected by other cards' effects
	-------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)

	-------------------------------------------------
	-- Gain ATK/DEF per Fusion Material
	-------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.matval)
	c:RegisterEffect(e2)

	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)

	-------------------------------------------------
	-- Shuffle 1 "Orichalcos" → Destroy 1 card → Gain ATK/DEF
	-------------------------------------------------
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCost(s.descost)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end

-------------------------------------------------
-- Immunity filter
-------------------------------------------------
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end

-------------------------------------------------
-- ATK/DEF per Fusion Material
-------------------------------------------------
function s.matval(e,c)
	return c:GetMaterialCount()*1000
end

-------------------------------------------------
-- Cost: shuffle 1 "Orichalcos"
-------------------------------------------------
function s.costfilter(c)
	return c:IsMonster() and c:IsSetCard(0x3e8)
		and c:IsAbleToDeckAsCost()
end


function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			s.costfilter,tp,
			LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE,
			0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,
		s.costfilter,tp,
		LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE,
		0,1,1,nil)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

-------------------------------------------------
-- Destroy 1 card and gain ATK/DEF
-------------------------------------------------
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			aux.TRUE,tp,
			LOCATION_ONFIELD,LOCATION_ONFIELD,
			1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,
		aux.TRUE,tp,
		LOCATION_ONFIELD,LOCATION_ONFIELD,
		1,1,nil)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0
		and c:IsRelateToEffect(e) then

		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)

		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
end
