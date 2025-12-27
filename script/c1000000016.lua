-- Slave Slime
local s,id=GetID()

function s.initial_effect(c)
	-- Quick Effect: Special Summon + negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
end

-----------------------------------------------------------
-- CONDITION
-----------------------------------------------------------
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
		and re:IsActiveType(TYPE_MONSTER)
		and Duel.IsChainNegatable(ev)
end

-----------------------------------------------------------
-- FILTERS
-----------------------------------------------------------
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-----------------------------------------------------------
-- TARGET
-----------------------------------------------------------
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
			and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,e:GetHandler(),e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

-----------------------------------------------------------
-- OPERATION
-----------------------------------------------------------
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	if not c:IsRelateToEffect(e) then return end

	-- Select WATER monster
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,c,e,tp)
	if #g==0 then return end

	g:AddCard(c)

	-- Special Summon both
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)==0 then return end

	-- Negate activation
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(re:GetHandler(),REASON_EFFECT)
	end

	-------------------------------------------------------
	-- EXTRA DECK RESTRICTION (REST OF TURN)
	-------------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.exlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

-----------------------------------------------------------
-- EXTRA DECK LIMIT
-----------------------------------------------------------
function s.exlimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
		and not c:IsAttribute(ATTRIBUTE_WATER)
end
