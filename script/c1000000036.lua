--Dvalinn of the Nordic Alfar
local s,id=GetID()
function s.initial_effect(c)

	--------------------------------
	-- Base Trait: Multiarquetipo
	-- (Cuenta como "Nordic Ascendant" y "Nordic Beast" además de "Nordic Alfar")
	--------------------------------
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x3042) -- Nordic Ascendant
	c:RegisterEffect(e0)
	local e00=e0:Clone()
	e00:SetValue(0x6042) -- Nordic Beast
	c:RegisterEffect(e00)

	--------------------------------
	-- ① Synchro Tuner Substitute
	-- Puede sustituir a cualquier "Nordic" Tuner para una Invocación Synchro
	--------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SYNCHRO_MATERIAL)
	e1:SetValue(s.synval)
	c:RegisterEffect(e1)

	--------------------------------
	-- ② Special Summon from hand
	-- Si no controlas monstruos o controlas un "Nordic"/"Aesir": Invoca esta carta de tu mano
	--------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)

	--------------------------------
	-- ③ Add self from GY to hand
	-- Si controlas un "Nordic"/"Aesir": descarta 1 carta o destierra 1 "Nordic" en tu GY; añade esta carta a tu mano
	--------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(s.thcon3)
	e3:SetCost(s.thcost3)
	e3:SetTarget(s.thtg3)
	e3:SetOperation(s.thop3)
	c:RegisterEffect(e3)
end

--------------------------------
-- Effect ①: Synchro Substitute Logic
--------------------------------
function s.synval(e,c)
	return c:IsSetCard(0x42) -- puede sustituir a cualquier "Nordic" Tuner
end

--------------------------------
-- Effect ②: Special Summon from hand
--------------------------------
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		or Duel.IsExistingMatchingCard(function(c) return c:IsSetCard(0x42) or c:IsSetCard(0x4b) end,tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--------------------------------
-- Effect ③: Add self from GY to hand
--------------------------------
function s.thcon3(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(function(c) return c:IsSetCard(0x42) or c:IsSetCard(0x4b) end,tp,LOCATION_MZONE,0,1,nil)
end
function s.thcost3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
			or Duel.IsExistingMatchingCard(function(c) return c:IsSetCard(0x42) end,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,function(c)
		return c:IsDiscardable() or c:IsSetCard(0x42)
	end,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc:IsLocation(LOCATION_HAND) then
		Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)
	else
		Duel.Remove(tc,POS_FACEUP,REASON_COST)
	end
end
function s.thtg3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function s.thop3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end
