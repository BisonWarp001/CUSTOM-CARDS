--The Ultimate Seal of Orichalcos
local s,id=GetID()

function s.initial_effect(c)
	--This card's name becomes "The Seal of Orchalcos" while on the field. 
		local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_FZONE)
	e0:SetValue(48179391)
	c:RegisterEffect(e0)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)

	--All monsters you control gain 500 ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(500)
	c:RegisterEffect(e2)

	--Lowest ATK monsters cannot be targeted for attacks
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	e3:SetValue(s.atlimit)
	c:RegisterEffect(e3)

	--Search or send Orichalcos monster
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id)
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TOGRAVE)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end

-- CONDITION: control 2 or more face-up Attack Position monsters
function s.atkcon(e)
	return Duel.IsExistingMatchingCard(Card.IsPosition,e:GetHandlerPlayer(),
		LOCATION_MZONE,0,2,nil,POS_FACEUP_ATTACK)
end

-- Check if monster has lower ATK
function s.atkfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()<atk
end

-- Prevent attack targeting lowest ATK monster(s)
function s.atlimit(e,c)
	return c:IsFaceup() and not Duel.IsExistingMatchingCard(
		s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,c,c:GetAttack())
end

-- Orichalcos monster filter
function s.orifilter(c)
	return c:IsMonster() and c:IsSetCard(0x3e8)
		and (c:IsAbleToHand() or c:IsAbleToGrave())
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.orifilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SEARCH,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local g=Duel.SelectMatchingCard(tp,s.orifilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end

	if tc:IsAbleToHand() and tc:IsAbleToGrave()
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	else
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
