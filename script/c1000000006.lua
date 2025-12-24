--Raviel, Emperor of Phantasmal Demons
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,1,id)
	--spsummon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e0)
	--Cannot Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	--Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Create Token
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(s.tokencon)
	e3:SetTarget(s.tokentg)
	e3:SetOperation(s.tokenop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e5)
	--Tribute to Increase ATK
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_ATKCHANGE)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetCost(s.atkcost)
	e6:SetOperation(s.atkop)
	c:RegisterEffect(e6)
	--cannot be tribute by your opponent
	local e21=Effect.CreateEffect(c)
	e21:SetType(EFFECT_TYPE_SINGLE)
	e21:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e21:SetRange(LOCATION_MZONE)
	e21:SetCode(EFFECT_UNRELEASABLE_SUM)
	e21:SetValue(s.sumlimit)
	c:RegisterEffect(e21)
	local e22=Effect.CreateEffect(c)
	e22:SetType(EFFECT_TYPE_FIELD)
	e22:SetCode(EFFECT_CANNOT_RELEASE)
	e22:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e22:SetRange(LOCATION_MZONE)
	e22:SetTargetRange(0,1)
	e22:SetTarget(s.relval)
	e22:SetValue(1)
	c:RegisterEffect(e22)
	--Control of this card cannot switch
	local e23=Effect.CreateEffect(c)
	e23:SetType(EFFECT_TYPE_SINGLE)
	e23:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	e23:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e23:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e23)
	--Effect immunity
	local e24=e23:Clone()
	e24:SetCode(EFFECT_IMMUNE_EFFECT)
	e24:SetValue(s.efilter)
	c:RegisterEffect(e24)
	local e25=e24:Clone()
	e25:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e25:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_RITUAL,SUMMON_TYPE_XYZ,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_LINK))
	c:RegisterEffect(e25)
end
	--Special Summon
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.CheckReleaseGroup(c:GetControler(),aux.TRUE,3,false,3,true,c,c:GetControler(),nil,false,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectReleaseGroup(tp,aux.TRUE,3,3,false,true,true,c,nil,nil,false,nil)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
	return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end
	--Create Token
function s.tokencon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
function s.tokentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=eg:FilterCount(Card.IsControler,nil,1-tp)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ct,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,0)
end
function s.tokenop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(Card.IsControler,nil,1-tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,69890968,0,TYPES_TOKEN,1000,1000,1,RACE_FIEND,ATTRIBUTE_DARK) then return end
	for i=1,ct do
		local token=Duel.CreateToken(tp,69890968)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
	end
	Duel.SpecialSummonComplete()
end
	--Tribute to Increase ATK
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,2,e:GetHandler()) end
	local g=Duel.SelectReleaseGroup(tp,nil,2,2,e:GetHandler())
	local atk=0
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	if tc1:IsFaceup() then atk=tc1:GetAttack() end
	if tc2:IsFaceup() then atk=atk+tc2:GetAttack() end
	if atk<0 then atk=0 end
	e:SetLabel(atk)
	Duel.Release(g,REASON_COST)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
--cannot be tribute by your opponent
function s.sumlimit(e,c)
	if not c then return false end
	return not c:IsControler(e:GetHandlerPlayer())
end
function s.relval(e,c)
	return c==e:GetHandler()
end
--unaffected by monsters except gods
function s.efilter(e,te,c)
	local tc=te:GetOwner()
		return (te:IsActiveType(TYPE_MONSTER) and c~=tc) and not tc:IsOriginalAttribute(ATTRIBUTE_DIVINE)
	end