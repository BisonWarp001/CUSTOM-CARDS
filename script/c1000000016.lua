--Slave Slime
local s,id=GetID()
function s.initial_effect(c)
	--Quick negate + Special Summon + Search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
end

-------------------------------------------------
-- Negate condition (monster effect)
-------------------------------------------------
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp
		and re:IsActiveType(TYPE_MONSTER)
		and Duel.IsChainNegatable(ev)
end

-------------------------------------------------
-- Target
-------------------------------------------------
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

-------------------------------------------------
-- Operation (PSY-Frame style)
-------------------------------------------------
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- Negate activation
		Duel.NegateActivation(ev)

		-- Search Slime / Guardian Slime
		if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			if #g>0 then
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
		end

		Duel.SpecialSummonComplete()

		-- Extra Deck WATER restriction
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.exlimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

-------------------------------------------------
-- Extra Deck restriction
-------------------------------------------------
function s.exlimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
		and not c:IsCode(42166000)
end

-------------------------------------------------
-- Search filter
-------------------------------------------------
function s.thfilter(c)
	return (c:IsSetCard(0x54b) or c:IsCode(15771991))
		and c:IsMonster()
		and not c:IsCode(id)
		and c:IsAbleToHand()
end
