--Orichalcos Kyutora
local s,id=GetID()
function s.initial_effect(c)

	--Special Summon from hand by paying 500 LP
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	--Special Summon "Orichalcos King Shunoros" when destroyed
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)

	--Battle damage involving "Orichalcos" monsters you control becomes 0
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CHANGE_DAMAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetValue(s.damval)
	c:RegisterEffect(e3)
end

s.listed_names={1000000049}

--Special Summon condition (pay 500 LP)
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLP(c:GetControler())>=500
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.PayLPCost(tp,500)
end

--Destroyed by battle or card effect
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end

--Shunoros filter
function s.spfilter(c,e,tp)
	return c:IsCode(1000000049)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--Battle damage becomes 0 if an "Orichalcos" monster you control is involved
function s.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_BATTLE)==0 then return val end
	local tp=e:GetHandlerPlayer()
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if (a and a:IsControler(tp) and a:IsSetCard(0x3e8)) or
	   (d and d:IsControler(tp) and d:IsSetCard(0x3e8)) then
		return 0
	end
	return val
end
