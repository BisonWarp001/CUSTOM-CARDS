--Wrath of the Heavens
--Scripted by mike warp & GPT-5
local s,id=GetID()
function s.initial_effect(c)
	--Cannot be negated
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
	e0:SetCountLimit(1,id)
	e0:SetTarget(s.target)
	e0:SetOperation(s.activate)
	c:RegisterEffect(e0)

	--Can activate the turn it was Set if you have 4+ cards in hand
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCondition(s.actcon)
	c:RegisterEffect(e1)

	--Grant DEF reduction effect to Slifer
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.grantop)
	c:RegisterEffect(e2)
end

------------------------------------------------------------
-- Conditions
------------------------------------------------------------
function s.actcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>=4
end

function s.filter(c)
	return c:IsAbleToHand() and (c:IsCode(10000020) or c:ListsCode(10000020)) and not c:IsCode(id)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

------------------------------------------------------------
-- Grant effect to Slifer
------------------------------------------------------------
function s.sliferfilter(c)
	return c:IsFaceup() and c:IsOriginalCode(10000020)
end

function s.grantop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local slifer=Duel.GetFirstMatchingCard(s.sliferfilter,tp,LOCATION_MZONE,0,nil)
	if slifer and slifer:GetFlagEffect(id)==0 then
		--Mark Slifer so it only receives the effect once
		slifer:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		
		--Create DEF reduction effect
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetCategory(CATEGORY_DEFCHANGE+CATEGORY_DESTROY)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_SUMMON_SUCCESS)
		e1:SetRange(LOCATION_MZONE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
		e1:SetTarget(s.deftg)
		e1:SetOperation(s.defop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		slifer:RegisterEffect(e1,true)
		
		local e2=e1:Clone()
		e2:SetCode(EVENT_SPSUMMON_SUCCESS)
		slifer:RegisterEffect(e2,true)
	end
end

------------------------------------------------------------
-- DEF reduction and destruction
------------------------------------------------------------
function s.deffilter(c,tp)
	return c:IsControler(1-tp) and c:IsPosition(POS_FACEUP_DEFENSE)
end

function s.deftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.deffilter,1,nil,tp) end
	local g=eg:Filter(s.deffilter,nil,tp)
	Duel.SetTargetCard(g)
end

function s.defop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e):Filter(Card.IsRelateToEffect,nil,e)
	if #g==0 then return end
	local dg=Group.CreateGroup()
	for tc in g:Iter() do
		local predef=tc:GetDefense()
		if predef>0 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_DEFENSE)
			e1:SetValue(-2000)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
			if tc:GetDefense()<=0 then dg:AddCard(tc) end
		end
	end
	if #dg>0 then
		Duel.BreakEffect()
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
