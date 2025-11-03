--The Terrifying God
local s,id=GetID()
function s.initial_effect(c)
	--① Activate: Special Summon "The Wicked Dreadroot" ignoring its Summoning conditions
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	
	--② GY effect: banish to grant conditional effects to 1 "The Wicked Dreadroot"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost) -- banish self as cost
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
end

s.listed_names={62180201} --The Wicked Dreadroot

--① Special Summon target
function s.spfilter(c,e,tp)
	return c:IsCode(62180201) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if not tc then return end
	if Duel.SpecialSummonStep(tc,0,tp,tp,true,true,POS_FACEUP)==0 then return end

	--Unaffected by opponent's effects until end of turn
	local e1=Effect.CreateEffect(tc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e,re) return e:GetOwnerPlayer()~=re:GetOwnerPlayer() end)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)

	Duel.SpecialSummonComplete()
end

--② GY target (target 1 Dreadroot)
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsFaceup() and chkc:IsCode(62180201) end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsCode,62180201),tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsCode,62180201),tp,LOCATION_MZONE,0,1,1,nil)
end

--② GY operation (conditional by turn)
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc and tc:IsRelateToEffect(e)) then return end
	if Duel.GetTurnPlayer()==tp then
		--Your turn → Dreadroot can attack all opponent monsters once each
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ATTACK_ALL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	else
		--Opponent's turn → all opponent monsters must attack this Dreadroot if able
		local e2=Effect.CreateEffect(tc)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
		e2:SetRange(LOCATION_MZONE)
		e2:SetTargetRange(0,LOCATION_MZONE)
		e2:SetValue(function(e,c) return c==tc end)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(tc)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_MUST_ATTACK)
		e3:SetRange(LOCATION_MZONE)
		e3:SetTargetRange(0,LOCATION_MZONE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
