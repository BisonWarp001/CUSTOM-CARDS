--Orichalcos Gigas
local s,id=GetID()

function s.initial_effect(c)
	--Special Summon from GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	--ATK increase based on self Special Summons
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
end

-- Special Summon target
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

-- Special Summon operation
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if not c:IsRelateToEffect(e) then return end

	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
	-- Count this Special Summon PERMANENTLY
		c:RegisterFlagEffect(id,0,0,0)

	-- Extra Deck restriction
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.sumlimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end

end

-- Extra Deck limit (except Orichalcos)
function s.sumlimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x3e8)
end

-- ATK = Special Summons by own effect × 500
function s.atkval(e,c)
	return c:GetFlagEffect(id)*500
end
