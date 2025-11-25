--Solar the God Priestess
local s,id=GetID()
function s.initial_effect(c)
	--① Special Summon from hand by revealing and sending Ra-related card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	--② Set 1 Ra Spell/Trap from Deck or GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+100)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)

	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end

-----------------------------------------
-- FILTERS
-----------------------------------------
function s.rafilter(c)
	-- Solo las 3 versiones exactas de Ra
	if c:IsCode(10000010,10000080,10000090) then return true end
	-- Cartas que mencionen a Ra
	return c:IsSpellTrap() and c:ListsCode(10000010,10000080,10000090)
end

function s.setfilter(c)
	return c:IsSpellTrap() and c:ListsCode(10000010,10000080,10000090) and c:IsSSetable()
end

-----------------------------------------
-- ① Reveal + Send to GY → Special Summon
-----------------------------------------
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return not e:GetHandler():IsPublic()
	end
	Duel.ConfirmCards(1-tp,e:GetHandler())
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.rafilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	local g=Duel.SelectMatchingCard(tp,s.rafilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

-----------------------------------------
-- ② Set S/T that mentions Ra from Deck or GY
-----------------------------------------
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	end
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if tc then
		Duel.SSet(tp,tc)

		-- Permitir activar este turno
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)

		local e2=e1:Clone()
		e2:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
		tc:RegisterEffect(e2)
	end
end
