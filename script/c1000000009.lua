--Polar God Emperor Thor
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
	--Effect Absorber
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	--negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)

	local eBan=Effect.CreateEffect(c)
	eBan:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	eBan:SetCode(EVENT_REMOVE)
	eBan:SetOperation(s.regop)
	c:RegisterEffect(eBan)

-- Special Summon al final de turno desde Cementerio
	local esp1=Effect.CreateEffect(c)
	esp1:SetDescription(aux.Stringid(67098114,1))
	esp1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	esp1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	esp1:SetCode(EVENT_PHASE+PHASE_END)
	esp1:SetRange(LOCATION_GRAVE)
	esp1:SetCountLimit(1)
	esp1:SetCondition(s.spcon)
	esp1:SetTarget(s.sptg)
	esp1:SetOperation(s.spop)
	c:RegisterEffect(esp1)

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
	--damage
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(30604579,2))
	e5:SetCategory(CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(s.damcon)
	e5:SetTarget(s.damtg)
	e5:SetOperation(s.damop)
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
-------------------------------------------------
--absorber
function s.efffilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and not c:IsDisabled()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.efffilter(chkc) end
	if chk==0 then 
		return Duel.IsExistingTarget(s.efffilter,tp,0,LOCATION_MZONE,1,nil) 
			and Duel.GetFlagEffect(tp,id+100)==0 -- NO se ha usado absorber o negate este turno
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.efffilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end

function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local code=tc:GetOriginalCode()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if Duel.SelectYesNo(tp,aux.Stringid(10032958,0)) then
			c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
		end
		-- Marca que ya se usó absorber o negate este turno
		Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE+PHASE_END,0,1)
	end
end
--negate
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
			and Duel.GetFlagEffect(tp,id+100)==0 -- NO se ha usado absorber o negate este turno
	end
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local c=e:GetHandler()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
	-- Marca que ya se usó absorber o negate este turno
	Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE+PHASE_END,0,1)
end
--return
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsPreviousControler(tp) then return end
	if not c:IsPreviousLocation(LOCATION_ONFIELD) then return end
	
	if bit.band(r,REASON_BATTLE)~=0 or bit.band(r,REASON_EFFECT)~=0 or bit.band(r,REASON_DESTROY)~=0 then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)~=0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,1,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SpecialSummon(e:GetHandler(),1,tp,tp,false,false,POS_FACEUP)
	end
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL+1)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(800)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
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