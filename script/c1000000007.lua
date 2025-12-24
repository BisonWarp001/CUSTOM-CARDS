--Hamon, Emperor of Descending Thunder
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
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
	--1000 Damage
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCondition(s.dmgcon)
	e3:SetTarget(s.dmgtg)
	e3:SetOperation(s.dmgop)
	c:RegisterEffect(e3)
	--Protect other Monsters
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e4:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e4:SetCondition(s.protectcon)
	e4:SetTarget(s.protecttg)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	--Damage 0 for the rest of Turn
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCondition(s.nodmgcon)
	e5:SetOperation(s.nodmgop)
	c:RegisterEffect(e5)
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
function s.spfilter(c)
	return c:IsSpell() and c:IsAbleToGraveAsCost()
end
function s.exfilter(c)
	return s.spfilter(c) or (c:IsFacedown() and c:IsSpell() and c:IsAbleToGraveAsCost())
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=nil
	if Duel.IsPlayerAffectedByEffect(tp,54828837) then
		g=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_ONFIELD,0,nil)
	else
		g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_ONFIELD,0,nil)
	end
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-3 and #g>2 and aux.SelectUnselectGroup(g,e,tp,3,3,aux.ChkfMMZ(1),0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local g=nil
	if Duel.IsPlayerAffectedByEffect(tp,54828837) then
		g=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_ONFIELD,0,nil)
	else
		g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_ONFIELD,0,nil)
	end
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,aux.ChkfMMZ(1),1,tp,HINTMSG_TOGRAVE,nil,nil,true)
	local dg=sg:Filter(Card.IsFacedown,nil)
	if #dg>0 then
		Duel.ConfirmCards(1-tp,dg)
	end
	if #sg==3 then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g,REASON_COST)
	g:DeleteGroup()
end
function s.dmgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsReason(REASON_BATTLE) and bc:IsMonster()
end
function s.dmgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
function s.dmgop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
function s.protectcon(e)
	return e:GetHandler():IsDefensePos()
end
function s.protecttg(e,c)
	return c~=e:GetHandler()
end
function s.nodmgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP_DEFENSE) and e:GetHandler():IsReason(REASON_DESTROY)
end
function s.nodmgop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e3:SetDescription(aux.Stringid(4016,2))
	e3:SetReset(RESET_PHASE+PHASE_END)
	e3:SetTargetRange(1,0)
	Duel.RegisterEffect(e3,tp)
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