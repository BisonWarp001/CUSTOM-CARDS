--Valhalla, Nordic Celestial Haven
local s,id=GetID()

function s.initial_effect(c)
	-- ① When activated: add 1 "Nordic" monster from Deck to hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg1)
	e1:SetOperation(s.thop1)
	c:RegisterEffect(e1)

	-- ② Protect your "Aesir" monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(function(e,c) return IsAesir(c) end)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	c:RegisterEffect(e3)

	-- ③ Once per turn: reduce Level and summon token
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id+100)
	e4:SetTarget(s.sptg3)
	e4:SetOperation(s.spop3)
	c:RegisterEffect(e4)
end

--------------------------------
-- Effect ①: Add 1 "Nordic" monster from Deck to hand
--------------------------------
function s.thfilter1(c)
	return IsNordic(c) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--------------------------------
-- Effect ③: Reduce Level of 1 Level 3+ "Nordic" and summon token
--------------------------------
function s.spfilter3(c,e,tp)
	return IsNordic(c) and c:IsFaceup() and c:GetLevel()>=3
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function s.sptg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter3,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.spop3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,s.spfilter3,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	if #g>0 then
		local tc=g:GetFirst()
		local lv=tc:GetLevel()
		if lv>=3 then
			local newlv=lv-2
			-- Cambia su Nivel directamente
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(newlv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		-- Luego invoca el token
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,1000000041,0,TYPES_TOKEN,2000,2000,2,RACE_WARRIOR,ATTRIBUTE_LIGHT) then
			local token=Duel.CreateToken(tp,1000000041)
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
