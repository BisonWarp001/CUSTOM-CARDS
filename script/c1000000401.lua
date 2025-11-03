--The Shapeshifter God
local s,id=GetID()
function s.initial_effect(c)
	--① Add "The Wicked Avatar" + extra Tribute Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--② Banish from GY: Opponent cannot activate Trap effects when you Normal Summon this turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost) -- destierra la carta como coste
	e2:SetOperation(s.protectop)
	c:RegisterEffect(e2)
end
s.listed_names={21208154} --The Wicked Avatar

--① Search
function s.thfilter(c)
	return c:IsCode(21208154) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		--extra tribute summon
		if Duel.GetFlagEffect(tp,id+100)==0 then
			Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE+PHASE_END,0,1)
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
			e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
			e1:SetTarget(aux.TargetBoolFunction(Card.IsSummonableCard))
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end

--② GY: Protect Normal Summons from Trap activations
function s.protectop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- solo una vez por turno
	if Duel.GetFlagEffect(tp,id+1)~=0 then return end
	Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE+PHASE_END,0,1)
    
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetOperation(s.protectlim)
	Duel.RegisterEffect(e1,tp)
end

-- aplica Chain Limit en el momento de la Normal Summon
function s.protectlim(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsSummonPlayer(tp) and tc:IsSummonType(SUMMON_TYPE_NORMAL) then
		Duel.SetChainLimitTillChainEnd(function(e2,rp2,tp2)
			return not (e2:IsActiveType(TYPE_TRAP) and rp2~=tp2)
		end)
	end
end
