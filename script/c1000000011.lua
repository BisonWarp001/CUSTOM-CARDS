--Loki, Lord of the Aesir
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),2,99)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,0,id)
	--spsummon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e0)
	--Negate Spell/Trap
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)

	local eBan=Effect.CreateEffect(c)
	eBan:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	eBan:SetCode(EVENT_REMOVE)
	eBan:SetOperation(s.regop)
	c:RegisterEffect(eBan)

-- Special Summon al final de turno desde Cementerio
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(67098114,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)

-- Special Summon al final de turno desde Zona Removida (si quieres que funcione ahí también)
	local eban1=Effect.CreateEffect(c)
	eban1:SetDescription(aux.Stringid(67098114,1))
	eban1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	eban1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	eban1:SetCode(EVENT_PHASE+PHASE_END)
	eban1:SetRange(LOCATION_REMOVED)
	eban1:SetCountLimit(1)
	eban1:SetCondition(s.spcon)
	eban1:SetTarget(s.sptg)
	eban1:SetOperation(s.spop)
	c:RegisterEffect(eban1)
	--salvage
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(67098114,2))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	--Destroy Spell/Trap
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
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
	local eY=Effect.CreateEffect(c)
	eY:SetType(EFFECT_TYPE_SINGLE)
	eY:SetCode(EFFECT_CANNOT_TURN_SET)
	eY:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	eY:SetRange(LOCATION_MZONE)
	c:RegisterEffect(eY)
	-- Cannot be returned to the hand
	local e27=Effect.CreateEffect(c)
	e27:SetType(EFFECT_TYPE_SINGLE)
	e27:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e27:SetRange(LOCATION_MZONE)
	e27:SetCode(EFFECT_CANNOT_TO_HAND)
	c:RegisterEffect(e27)

-- Cannot be returned to the Deck
	local e28=e27:Clone()
	e28:SetCode(EFFECT_CANNOT_TO_DECK)
	c:RegisterEffect(e28)
end
----------------------------------------------------
	--Negate Spell/Trap
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	local seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_SEQUENCE)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.GetAttacker()==e:GetHandler()
		and ep~=tp and loc==LOCATION_SZONE and seq<5 and Duel.IsChainNegatable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
--special summon
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsPreviousControler(tp) then return end
	if not c:IsPreviousLocation(LOCATION_ONFIELD) then return end
	
	if bit.band(r,REASON_BATTLE)~=0 or bit.band(r,REASON_EFFECT)~=0 or bit.band(r,REASON_DESTROY)~=0 then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end

-- Target para special summon
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,1,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

-- Operación para special summon
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,1,tp,tp,false,false,POS_FACEUP)
	end
end
	--salvage
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+1
end
function s.thfilter(c)
	return c:IsTrap() or c:IsSpell() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end
	--Destroy Spell/Trap
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) and chkc:IsFacedown() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,0,LOCATION_SZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,0,LOCATION_SZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetChainLimit(s.chainlimit)
end
function s.chainlimit(e,rp,tp)
	return not e:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFacedown() and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
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
--unaffected by monster effects except gods
function s.leaveChk(c,category)
	local ex,tg=Duel.GetOperationInfo(0,category)
	return ex and tg~=nil and tg:IsContains(c)
end
function s.efilter(e,te,c)
	local tc=te:GetOwner()
		return (te:IsActiveType(TYPE_MONSTER) and c~=tc) and not tc:IsOriginalAttribute(ATTRIBUTE_DIVINE)
	end